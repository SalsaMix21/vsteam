Set-StrictMode -Version Latest

InModuleScope VSTeam {

   Describe 'Pull Requests' {
      . "$PSScriptRoot\mocks\mockProjectNameDynamicParamNoPSet.ps1"

      Mock _getInstance { return 'https://dev.azure.com/test' } -Verifiable

      # You have to set the version or the api-version will not be added when
      # [VSTeamVersions]::Core = ''
      [VSTeamVersions]::Git = '5.1-preview'
      [VSTeamVersions]::Graph = '5.0'

      $result = Get-Content "$PSScriptRoot\sampleFiles\updatePullRequestResponse.json" -Raw | ConvertFrom-Json
      $userSingleResult = Get-Content "$PSScriptRoot\sampleFiles\users.single.json" -Raw | ConvertFrom-Json

      Context 'Update-VSTeamPullRequest' {

         It 'Update-VSTeamPullRequest to Draft' {
            Mock Invoke-RestMethod { return $result }

            Update-VSTeamPullRequest -RepositoryId "45df2d67-e709-4557-a7f9-c6812b449277" -PullRequestId 19543 -Draft -Force

            Assert-MockCalled Invoke-RestMethod -Scope It -ParameterFilter {
               $Method -eq 'Patch' -and
               $Uri -like "*repositories/45df2d67-e709-4557-a7f9-c6812b449277/*" -and
               $Uri -like "*pullrequests/19543*" -and
               $Body -eq '{"isDraft": true }'
            }
         }

         It 'Update-VSTeamPullRequest to Published' {
            Mock Invoke-RestMethod { return $result }

            Update-VSTeamPullRequest -RepositoryId "45df2d67-e709-4557-a7f9-c6812b449277" -PullRequestId 19543 -Force

            Assert-MockCalled Invoke-RestMethod -Scope It -ParameterFilter {
               $Method -eq 'Patch' -and
               $Uri -like "*repositories/45df2d67-e709-4557-a7f9-c6812b449277/*" -and
               $Uri -like "*pullrequests/19543*" -and
               $Body -eq '{"isDraft": false }'
            }
         }

         It 'Update-VSTeamPullRequest to set status to abandoned' {
            Mock Invoke-RestMethod { return $result }

            Update-VSTeamPullRequest -RepositoryId "45df2d67-e709-4557-a7f9-c6812b449277" -PullRequestId 19543 -Status abandoned -Force

            Assert-MockCalled Invoke-RestMethod -Exactly -Scope It -Times 1 -ParameterFilter {
               $Method -eq 'Patch' -and
               $Uri -like "*repositories/45df2d67-e709-4557-a7f9-c6812b449277/*" -and
               $Uri -like "*pullrequests/19543*" -and
               $Body -eq '{"status": "abandoned"}'
            }
         }

         It 'Update-VSTeamPullRequest to set to enable auto complete' {
            Mock Invoke-RestMethod { return $userSingleResult }

            $user = Get-VSTeamUser -Descriptor "aad.OTcyOTJkNzYtMjc3Yi03OTgxLWIzNDMtNTkzYmM3ODZkYjlj"

            Mock Invoke-RestMethod { return $result }
            Update-VSTeamPullRequest -RepositoryId "45df2d67-e709-4557-a7f9-c6812b449277" -PullRequestId 19543 -EnableAutoComplete -AutoCompleteIdentity $user -Force

            Assert-MockCalled Invoke-RestMethod -Scope It -ParameterFilter {
               $Method -eq 'Patch' -and
               $Uri -like "*repositories/45df2d67-e709-4557-a7f9-c6812b449277/*" -and
               $Uri -like "*pullrequests/19543*" -and
               $Body -eq '{"autoCompleteSetBy": "aad.OTcyOTJkNzYtMjc3Yi03OTgxLWIzNDMtNTkzYmM3ODZkYjlj"}'
            }
         }

         It 'Update-VSTeamPullRequest to set to disable auto complete' {
            Mock Invoke-RestMethod { return $result }
            Update-VSTeamPullRequest -RepositoryId "45df2d67-e709-4557-a7f9-c6812b449277" -PullRequestId 19543 -DisableAutoComplete -Force

            Assert-MockCalled Invoke-RestMethod -Scope It -ParameterFilter {
               $Method -eq 'Patch' -and
               $Uri -like "*repositories/45df2d67-e709-4557-a7f9-c6812b449277/*" -and
               $Uri -like "*pullrequests/19543*" -and
               $Body -eq '{"autoCompleteSetBy": null}'
            }
         }
      }
   }
}