[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'SPOApp' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PnPTenantAppCatalogUrl -MockWith {
                return 'https://contoso-admin.sharepoint.com'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the app doesn't already exist in the catalog" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'MyTestApp'
                    Path       = 'C:\Test\MyTestApp.sppkg'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-PnPApp -MockWith {
                    return $null
                }

                Mock -CommandName Add-PnPApp -MockWith {
                }
            }

            It 'Should return absent from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should add the App in the Set method' {
                Set-TargetResource @testParams
            }
        }

        Context -Name 'The app already exists and it should' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'MyTestApp'
                    Path       = 'C:\Test\MyTestApp.sppkg'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-PnPApp -MockWith {
                    return @{
                        Title    = 'MyTestApp'
                        Deployed = $true
                    }
                }
            }

            It 'Should return Present from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name 'The app already exists and it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'MyTestApp'
                    Path       = 'C:\Test\MyTestApp.sppkg'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-PnPApp -MockWith {
                    return @{
                        Identity = 'MyTestApp'
                        Deployed = $true
                    }
                }

                Mock -CommandName Remove-PnPApp -MockWith {
                }
            }

            It 'Should remove the app from the set method' {
                Set-TargetResource @testParams
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-PnPTenantAppCatalogUrl -MockWith {
                    return 'https://contoso-admin.sharepoint.com'
                }

                Mock -Command Get-AllSPOPackages -MockWith {
                    return @(@{
                            Name  = 'TestPkg.sppkg'
                            Site  = 'https://contoso.sharepoint.com/sites/apps'
                            Title = 'Test Pkg'
                        },
                        @{
                            Name  = 'TestApp.app'
                            Site  = 'https://contoso.sharepoint.com/sites/apps'
                            Title = 'Test App'
                        }
                    )
                }

                Mock -CommandName Get-PnPApp -MockWith {
                    return @{
                        Identity = 'MyTestApp'
                        Deployed = $true
                    }
                }

                Mock -CommandName Get-PnPFile -MockWith {
                    return @{
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Export-TargetResource @testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
