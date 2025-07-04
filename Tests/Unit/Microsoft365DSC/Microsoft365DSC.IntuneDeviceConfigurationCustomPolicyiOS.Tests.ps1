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
    -DscResource 'IntuneDeviceConfigurationCustomPolicyiOS' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {

                return @()
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the IntuneDeviceConfigurationCustomPolicyiOS doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Description     = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                    Payload         = 'PHJvb3Q+PC9yb290Pg=='
                    PayloadFileName = 'simple.xml'
                    PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should create the IntuneDeviceConfigurationCustomPolicyiOS from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceConfiguration' -Exactly 1
            }
        }

        Context -Name 'When the IntuneDeviceConfigurationCustomPolicyiOS already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Description     = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                    Payload         = 'PHJvb3Q+PC9yb290Pg=='
                    PayloadFileName = 'simple.xml'
                    PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName          = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                        Description          = 'Different Value'
                        Id                   = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        AdditionalProperties = @{
                            Payload         = 'PHJvb3Q+PC9yb290Pg=='
                            PayloadFileName = 'simple.xml'
                            PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                            '@odata.type'   = '#microsoft.graph.iosCustomConfiguration'
                        }
                    }
                }
            }

            It 'Should return Present from the Get method' {
                    (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should update the IntuneDeviceConfigurationCustomPolicyiOS from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1

            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Description     = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                    Payload         = 'PHJvb3Q+PC9yb290Pg=='
                    PayloadFileName = 'simple.xml'
                    PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName          = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                        Description          = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                        Id                   = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        AdditionalProperties = @{
                            Payload         = 'PHJvb3Q+PC9yb290Pg=='
                            PayloadFileName = 'simple.xml'
                            PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                            '@odata.type'   = '#microsoft.graph.iosCustomConfiguration'
                        }
                    }
                }
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Description     = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                    Payload         = 'PHJvb3Q+PC9yb290Pg=='
                    PayloadFileName = 'simple.xml'
                    PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                    Ensure          = 'Absent'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName          = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                        Description          = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                        Id                   = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        AdditionalProperties = @{
                            Payload         = 'PHJvb3Q+PC9yb290Pg=='
                            PayloadFileName = 'simple.xml'
                            PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                            '@odata.type'   = '#microsoft.graph.iosCustomConfiguration'
                        }
                    }
                }
            }

            It 'Should return Present from the Get method' {
                    (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should remove the IntuneDeviceConfigurationCustomPolicyiOS from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        DisplayName          = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                        Description          = 'Test IntuneDeviceConfigurationCustomPolicyiOS Description'
                        Id                   = 'e30954ac-a65e-4dcb-ab79-91d45f3c52b4'
                        AdditionalProperties = @{
                            Payload         = 'PHJvb3Q+PC9yb290Pg=='
                            PayloadFileName = 'simple.xml'
                            PayloadName     = 'Test IntuneDeviceConfigurationCustomPolicyiOS'
                            '@odata.type'   = '#microsoft.graph.iosCustomConfiguration'
                        }
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
