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
    -DscResource 'AADGroupsNamingPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDirectorySetting -MockWith {
            }

            Mock -CommandName Remove-MgBetaDirectorySetting -MockWith {
            }

            Mock -CommandName New-MgBetaDirectorySetting -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credentials"
            }
        }

        # Test contexts
        Context -Name 'The Policy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $Script:calledOnceAlready = $false
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    PrefixSuffixNamingRequirement = '[Title]Bob[Company][GroupName][Office]Nik'
                    CustomBlockedWordsList        = @('CEO', 'Test')
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return 'Credentials'
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }


            BeforeEach {
                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    if (-not $Script:calledOnceAlready)
                    {
                        $Script:calledOnceAlready = $true
                        return $null
                    }
                    else
                    {
                        Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                            return @{
                                DisplayName = 'Group.Unified'
                                Values      = @(
                                    @{
                                        Name  = 'PrefixSuffixNamingRequirement'
                                        Value = '[Title]Bob[Company][GroupName][Office]Nik'
                                    },
                                    @{
                                        Name  = 'CustomBlockedWordsList'
                                        Value = @('CEO', 'Test')
                                    }
                                )
                            }
                        }
                    }
                }
            }
            It 'Should return false from the Test method' {
                $Script:calledOnceAlready = $false
                Test-TargetResource @testParams | Should -Be $false
            }

            BeforeEach {
                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    if (-not $Script:calledOnceAlready)
                    {
                        $Script:calledOnceAlready = $true
                        return $null
                    }
                    else
                    {
                        Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                            return @{
                                DisplayName = 'Group.Unified'
                                Values      = @(
                                    @{
                                        Name  = 'PrefixSuffixNamingRequirement'
                                        Value = '[Title]Bob[Company][GroupName][Office]Nik'
                                    },
                                    @{
                                        Name  = 'CustomBlockedWordsList'
                                        Value = @('CEO', 'Test')
                                    }
                                )
                            }
                        }
                    }
                }
            }
            It 'Should Create the Policy from the Set method' {
                $Script:calledOnceAlready = $false
                Set-TargetResource @testParams
                Should -Invoke -CommandName 'New-MgBetaDirectorySetting' -Exactly 1
                Should -Invoke -CommandName 'Update-MgBetaDirectorySetting' -Exactly 1
            }
        }

        Context -Name 'The Policy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    PrefixSuffixNamingRequirement = '[Title]Bob[Company][GroupName][Office]Nik'
                    CustomBlockedWordsList        = @('CEO', 'Test')
                    Ensure                        = 'Absent'
                    Credential                    = $Credential
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    return @{
                        DisplayName = 'Group.Unified'
                        Values      = @(
                            @{
                                Name  = 'PrefixSuffixNamingRequirement'
                                Value = '[Title]Bob[Company][GroupName][Office]Nik'
                            },
                            @{
                                Name  = 'CustomBlockedWordsList'
                                Value = @('CEO', 'Test')
                            }
                        )
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName 'Remove-MgBetaDirectorySetting' -Exactly 1
            }
        }
        Context -Name 'The Policy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    PrefixSuffixNamingRequirement = '[Title]Bob[Company][GroupName][Office]Nik'
                    CustomBlockedWordsList        = @('CEO', 'Test')
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    return @{
                        DisplayName = 'Group.Unified'
                        Values      = @(
                            @{
                                Name  = 'PrefixSuffixNamingRequirement'
                                Value = '[Title]Bob[Company][GroupName][Office]Nik'
                            },
                            @{
                                Name  = 'CustomBlockedWordsList'
                                Value = @('CEO', 'Test')
                            }
                        )
                    }
                }
            }

            It 'Should return Values from the Get method' {
                Get-TargetResource @testParams
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name 'Values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance              = 'Yes'
                    PrefixSuffixNamingRequirement = '[GroupName]Drift' #Drift
                    CustomBlockedWordsList        = @('CEO', 'Test')
                    Ensure                        = 'Present'
                    Credential                    = $Credential
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    return @{
                        DisplayName = 'Group.Unified'
                        Values      = @{
                            PrefixSuffixNamingRequirement = '[Title]Bob[Company][GroupName][Office]Nik'
                            CustomBlockedWordsList        = @('CEO', 'Test')
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                Get-TargetResource @testParams
                Should -Invoke -CommandName 'Get-MgBetaDirectorySetting' -Exactly 1
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should call the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName 'Update-MgBetaDirectorySetting' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName New-M365DSCConnection -MockWith {
                    return 'Credentials'
                }

                Mock -CommandName Get-MgBetaDirectorySetting -MockWith {
                    return @{
                        DisplayName = 'Group.Unified'
                        Values      = @(
                            @{
                                Name  = 'PrefixSuffixNamingRequirement'
                                Value = '[Title]Bob[Company][GroupName][Office]Nik'
                            },
                            @{
                                Name  = 'CustomBlockedWordsList'
                                Value = @('CEO', 'Test')
                            }
                        )
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
