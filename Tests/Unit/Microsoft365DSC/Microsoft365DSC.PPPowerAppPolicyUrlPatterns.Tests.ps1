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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credentials"
            }

            Mock -commandName Remove-PowerAppPolicyUrlPatterns -MockWith {}
            Mock -commandName Get-PowerAppPolicyUrlPatterns -MockWith {}
            Mock -commandName New-PowerAppPolicyUrlPatterns -MockWith {}
            Mock -commandName Get-TenantDetailsFromGraph -MockWith {
                return @{
                    TenantId = 'xxxxxxx'
                }
            }

            # Mock Write-Host to hide output during the tests
            Mock -CommandName Write-Host -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    PolicyName            = "DSCPolicy";
                    PPTenantId            = "xxxxxxx";
                    RuleSet               = @(
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://contoso.com'
                            customConnectorRuleClassification = 'General'
                            order = 1
                        } -ClientOnly)
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://fabrikam.com'
                            customConnectorRuleClassification = 'General'
                            order = 2
                        } -ClientOnly)
                    )
                    Ensure              = 'Absent'
                    Credential          = $Credential;
                }

                $Global:count = 1
                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    if ($Global:count -eq 1)
                    {
                        $Global:count++
                        return @{
                            value = @(
                                @{
                                    PolicyName  = "MyPolicy"
                                    properties = @{
                                        displayName = "DSCPolicy"
                                        definition = @{
                                            constraints = @{
                                                environmentFilter1 = @{
                                                    parameters = @{
                                                        environments = @{
                                                            name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                        }
                                                        filterType = 'include'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    elseif ($Global:count -eq 2)
                    {
                        $Global:count++
                        return @{
                            rules = @(
                                @{
                                    pattern = 'https://contoso.com'
                                    customConnectorRuleClassification = 'General'
                                    order = 1
                                },
                                @{
                                    pattern = 'https://fabrikam.com'
                                    customConnectorRuleClassification = 'General'
                                    order = 2
                                }
                            )
                        }
                    }
                    else
                    {
                        return
                    }
                }
            }
            It 'Should return Values from the Get method' {
                $Global:count = 1
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                $Global:count = 1
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                $Global:count = 1
                Set-TargetResource @testParams
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 2
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    PolicyName            = "DSCPolicy";
                    PPTenantId            = "xxxxxxx";
                    RuleSet               = @(
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://contoso.com'
                            customConnectorRuleClassification = 'General'
                            order = 1
                        } -ClientOnly)
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://fabrikam.com'
                            customConnectorRuleClassification = 'General'
                            order = 2
                        } -ClientOnly)
                    )
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                $Global:count = 1
                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    if ($Global:count -eq 1)
                    {
                        $Global:count++
                        return @{
                            value = @(
                                @{
                                    PolicyName  = "MyPolicy"
                                    properties = @{
                                        displayName = "DSCPolicy"
                                        definition = @{
                                            constraints = @{
                                                environmentFilter1 = @{
                                                    parameters = @{
                                                        environments = @{
                                                            name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                        }
                                                        filterType = 'include'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    elseif ($Global:count -eq 2)
                    {
                        $Global:count++
                        return @{
                            rules = @(
                                @{
                                    pattern = 'https://contoso.com'
                                    customConnectorRuleClassification = 'General'
                                    order = 1
                                },
                                @{
                                    pattern = 'https://fabrikam.com'
                                customConnectorRuleClassification = 'General'
                                order = 2
                                }
                            )
                        }
                    }
                    else
                    {
                        return
                    }
                }
            }

            It 'Should return true from the Test method' {
                $Global:count = 1
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    PolicyName            = "DSCPolicy";
                    PPTenantId            = "xxxxxxx";
                    RuleSet               = @(
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://contoso.com'
                            customConnectorRuleClassification = 'General'
                            order = 1
                        } -ClientOnly)
                        (New-CimInstance -ClassName MSFT_PPPowerAPpPolicyUrlPatternsRule -Property @{
                            pattern = 'https://tailspintoys.com' #drift
                            customConnectorRuleClassification = 'General'
                            order = 2
                        } -ClientOnly)
                    )
                    Ensure              = 'Present'
                    Credential          = $Credential;
                }

                $Global:count = 1
                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    if ($Global:count -eq 1)
                    {
                        $Global:count++
                        return @{
                            value = @(
                                @{
                                    PolicyName  = "MyPolicy"
                                    properties = @{
                                        displayName = "DSCPolicy"
                                        definition = @{
                                            constraints = @{
                                                environmentFilter1 = @{
                                                    parameters = @{
                                                        environments = @{
                                                            name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                        }
                                                        filterType = 'include'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    elseif ($Global:count -eq 2)
                    {
                        $Global:count++
                        return @{
                            rules = @(
                                @{
                                    pattern = 'https://contoso.com'
                                    customConnectorRuleClassification = 'General'
                                    order = 1
                                },
                                @{
                                    pattern = 'https://fabrikam.com'
                                customConnectorRuleClassification = 'General'
                                order = 2
                                }
                            )
                        }
                    }
                    else
                    {
                        return
                    }
                }
            }

            It 'Should return Values from the Get method' {
                $Global:count = 1
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                $Global:count = 1
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should call the Set method' {
                $Global:count = 1
                Set-TargetResource @testParams
                Should -Invoke -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -Exactly 2
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                $Global:count = 1
                Mock -CommandName Invoke-M365DSCPowerPlatformRESTWebRequest -MockWith {
                    if ($Global:count -eq 1 -or $Global:count -eq 2)
                    {
                        $Global:count++
                        return @{
                            value = @(
                                @{
                                    type = 'Microsoft.BusinessAppPlatform/scopes/apiPolicies'
                                    PolicyName  = "MyPolicy"
                                    properties = @{
                                        displayName = "DSCPolicy"
                                        definition = @{
                                            constraints = @{
                                                environmentFilter1 = @{
                                                    parameters = @{
                                                        environments = @{
                                                            name = 'Default-xxxxx-xxxxx-xxxxx-xxxxx-xxxxx'
                                                        }
                                                        filterType = 'include'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    elseif ($Global:count -eq 3)
                    {
                        $Global:count++
                        return @{
                            rules = @(
                                @{
                                    pattern = 'https://contoso.com'
                                    customConnectorRuleClassification = 'General'
                                    order = 1
                                },
                                @{
                                    pattern = 'https://fabrikam.com'
                                customConnectorRuleClassification = 'General'
                                order = 2
                                }
                            )
                        }
                    }
                    else
                    {
                        return
                    }
                }
                Mock -CommandName Get-MgContext -MockWith {
                    return @{
                        tenantId = '1234'
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $Global:count = 1
                $result = Export-TargetResource @testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
