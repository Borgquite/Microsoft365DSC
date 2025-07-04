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
    -DscResource 'IntuneDeviceCompliancePolicyWindows10' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Invoke-MgGraphRequest -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -MockWith {
                return @()
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementNotificationMessageTemplate -MockWith {
                return @()
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Write-Verbose -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Windows 10  Device Compliance Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Windows 10 DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordRequiredToUnlockFromIdle            = $True
                    PasswordMinutesOfInactivityBeforeLock       = 15
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'Devicedefault'
                    RequireHealthyDeviceReport                  = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 10.19
                    MobileOsMinimumVersion                      = 10
                    MobileOsMaximumVersion                      = 10.19
                    EarlyLaunchAntiMalwareDriverEnabled         = $False
                    BitLockerEnabled                            = $False
                    SecureBootEnabled                           = $True
                    CodeIntegrityEnabled                        = $True
                    StorageRequireEncryption                    = $True
                    ActiveFirewallRequired                      = $True
                    DefenderEnabled                             = $True
                    DefenderVersion                             = ''
                    SignatureOutOfDate                          = $True
                    RtpEnabled                                  = $True
                    AntivirusRequired                           = $True
                    AntiSpywareRequired                         = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                    ConfigurationManagerComplianceRequired      = $False
                    TPMRequired                                 = $False
                    DeviceCompliancePolicyScript                = $null
                    ValidOperatingSystemBuildRanges             = @()
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should create the Windows 10 Device Compliance Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementDeviceCompliancePolicy' -Exactly 1
            }
        }

        Context -Name 'When the Windows 10 Device Compliance Policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Windows 10 DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordRequiredToUnlockFromIdle            = $True
                    PasswordMinutesOfInactivityBeforeLock       = 15
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'Devicedefault'
                    RequireHealthyDeviceReport                  = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 10.19
                    MobileOsMinimumVersion                      = 10
                    MobileOsMaximumVersion                      = 10.19
                    EarlyLaunchAntiMalwareDriverEnabled         = $False
                    BitLockerEnabled                            = $False
                    SecureBootEnabled                           = $True
                    CodeIntegrityEnabled                        = $True
                    StorageRequireEncryption                    = $True
                    ActiveFirewallRequired                      = $True
                    DefenderEnabled                             = $True
                    DefenderVersion                             = ''
                    SignatureOutOfDate                          = $True
                    RtpEnabled                                  = $True
                    AntivirusRequired                           = $True
                    AntiSpywareRequired                         = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                    ConfigurationManagerComplianceRequired      = $False
                    TPMRequired                                 = $False
                    DeviceCompliancePolicyScript                = $null
                    ValidOperatingSystemBuildRanges             = @()
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return @{
                        DisplayName          = 'Windows 10 DSC Policy'
                        Description          = 'Test policy'
                        Id                   = 'f38b283d-d893-4c33-b6d2-d3bcb5f2dcc2'
                        AdditionalProperties = @{
                            '@odata.type'                               = '#microsoft.graph.windows10CompliancePolicy'
                            PasswordRequired                            = $False
                            PasswordBlockSimple                         = $True; #Drift
                            PasswordRequiredToUnlockFromIdle            = $True
                            PasswordMinutesOfInactivityBeforeLock       = 15
                            PasswordExpirationDays                      = 365
                            PasswordMinimumLength                       = 6
                            PasswordPreviousPasswordBlockCount          = 13
                            PasswordMinimumCharacterSetCount            = 1
                            PasswordRequiredType                        = 'Devicedefault'
                            RequireHealthyDeviceReport                  = $True
                            OsMinimumVersion                            = 10
                            OsMaximumVersion                            = 10.19
                            MobileOsMinimumVersion                      = 10
                            MobileOsMaximumVersion                      = 10.19
                            EarlyLaunchAntiMalwareDriverEnabled         = $False
                            BitLockerEnabled                            = $False
                            SecureBootEnabled                           = $True
                            CodeIntegrityEnabled                        = $True
                            StorageRequireEncryption                    = $True
                            ActiveFirewallRequired                      = $True
                            DefenderEnabled                             = $True
                            DefenderVersion                             = ''
                            SignatureOutOfDate                          = $True
                            RtpEnabled                                  = $True
                            AntivirusRequired                           = $True
                            AntiSpywareRequired                         = $True
                            DeviceThreatProtectionEnabled               = $True
                            DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                            ConfigurationManagerComplianceRequired      = $False
                            TPMRequired                                 = $False
                            DeviceCompliancePolicyScript                = $null
                            ValidOperatingSystemBuildRanges             = @()
                            RoleScopeTagIds                             = '0'
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

            It 'Should update the iOS Device Compliance Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                                 = 'Windows 10 DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordRequiredToUnlockFromIdle            = $True
                    PasswordMinutesOfInactivityBeforeLock       = 15
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'Devicedefault'
                    RequireHealthyDeviceReport                  = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 10.19
                    MobileOsMinimumVersion                      = 10
                    MobileOsMaximumVersion                      = 10.19
                    EarlyLaunchAntiMalwareDriverEnabled         = $False
                    BitLockerEnabled                            = $False
                    SecureBootEnabled                           = $True
                    CodeIntegrityEnabled                        = $True
                    StorageRequireEncryption                    = $True
                    ActiveFirewallRequired                      = $True
                    DefenderEnabled                             = $True
                    DefenderVersion                             = ''
                    SignatureOutOfDate                          = $True
                    RtpEnabled                                  = $True
                    AntivirusRequired                           = $True
                    AntiSpywareRequired                         = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                    ConfigurationManagerComplianceRequired      = $False
                    TPMRequired                                 = $False
                    DeviceCompliancePolicyScript                = $null
                    ValidOperatingSystemBuildRanges             = @()
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return @{
                        DisplayName          = 'Windows 10 DSC Policy'
                        Description          = 'Test policy'
                        Id                   = 'f38b283d-d893-4c33-b6d2-d3bcb5f2dcc2'
                        AdditionalProperties = @{
                            '@odata.type'                               = '#microsoft.graph.windows10CompliancePolicy'
                            PasswordRequired                            = $False
                            PasswordBlockSimple                         = $False
                            PasswordRequiredToUnlockFromIdle            = $True
                            PasswordMinutesOfInactivityBeforeLock       = 15
                            PasswordExpirationDays                      = 365
                            PasswordMinimumLength                       = 6
                            PasswordPreviousPasswordBlockCount          = 13
                            PasswordMinimumCharacterSetCount            = 1
                            PasswordRequiredType                        = 'Devicedefault'
                            RequireHealthyDeviceReport                  = $True
                            OsMinimumVersion                            = 10
                            OsMaximumVersion                            = 10.19
                            MobileOsMinimumVersion                      = 10
                            MobileOsMaximumVersion                      = 10.19
                            EarlyLaunchAntiMalwareDriverEnabled         = $False
                            BitLockerEnabled                            = $False
                            SecureBootEnabled                           = $True
                            CodeIntegrityEnabled                        = $True
                            StorageRequireEncryption                    = $True
                            ActiveFirewallRequired                      = $True
                            DefenderEnabled                             = $True
                            DefenderVersion                             = ''
                            SignatureOutOfDate                          = $True
                            RtpEnabled                                  = $True
                            AntivirusRequired                           = $True
                            AntiSpywareRequired                         = $True
                            DeviceThreatProtectionEnabled               = $True
                            DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                            ConfigurationManagerComplianceRequired      = $False
                            TPMRequired                                 = $False
                            DeviceCompliancePolicyScript                = $null
                            ValidOperatingSystemBuildRanges             = @()
                            RoleScopeTagIds                             = '0'
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
                    DisplayName                                 = 'Windows 10 DSC Policy'
                    Description                                 = 'Test policy'
                    PasswordRequired                            = $False
                    PasswordBlockSimple                         = $False
                    PasswordRequiredToUnlockFromIdle            = $True
                    PasswordMinutesOfInactivityBeforeLock       = 15
                    PasswordExpirationDays                      = 365
                    PasswordMinimumLength                       = 6
                    PasswordPreviousPasswordBlockCount          = 13
                    PasswordMinimumCharacterSetCount            = 1
                    PasswordRequiredType                        = 'Devicedefault'
                    RequireHealthyDeviceReport                  = $True
                    OsMinimumVersion                            = 10
                    OsMaximumVersion                            = 10.19
                    MobileOsMinimumVersion                      = 10
                    MobileOsMaximumVersion                      = 10.19
                    EarlyLaunchAntiMalwareDriverEnabled         = $False
                    BitLockerEnabled                            = $False
                    SecureBootEnabled                           = $True
                    CodeIntegrityEnabled                        = $True
                    StorageRequireEncryption                    = $True
                    ActiveFirewallRequired                      = $True
                    DefenderEnabled                             = $True
                    DefenderVersion                             = ''
                    SignatureOutOfDate                          = $True
                    RtpEnabled                                  = $True
                    AntivirusRequired                           = $True
                    AntiSpywareRequired                         = $True
                    DeviceThreatProtectionEnabled               = $True
                    DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                    ConfigurationManagerComplianceRequired      = $False
                    TPMRequired                                 = $False
                    DeviceCompliancePolicyScript                = $null
                    ValidOperatingSystemBuildRanges             = @()
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return @{
                        DisplayName          = 'Windows 10 DSC Policy'
                        Description          = 'Test policy'
                        Id                   = 'f38b283d-d893-4c33-b6d2-d3bcb5f2dcc2'
                        AdditionalProperties = @{
                            '@odata.type'                               = '#microsoft.graph.windows10CompliancePolicy'
                            PasswordRequired                            = $False
                            PasswordBlockSimple                         = $False
                            PasswordRequiredToUnlockFromIdle            = $True
                            PasswordMinutesOfInactivityBeforeLock       = 15
                            PasswordExpirationDays                      = 365
                            PasswordMinimumLength                       = 6
                            PasswordPreviousPasswordBlockCount          = 13
                            PasswordMinimumCharacterSetCount            = 1
                            PasswordRequiredType                        = 'Devicedefault'
                            RequireHealthyDeviceReport                  = $True
                            OsMinimumVersion                            = 10
                            OsMaximumVersion                            = 10.19
                            MobileOsMinimumVersion                      = 10
                            MobileOsMaximumVersion                      = 10.19
                            EarlyLaunchAntiMalwareDriverEnabled         = $False
                            BitLockerEnabled                            = $False
                            SecureBootEnabled                           = $True
                            CodeIntegrityEnabled                        = $True
                            StorageRequireEncryption                    = $True
                            ActiveFirewallRequired                      = $True
                            DefenderEnabled                             = $True
                            DefenderVersion                             = ''
                            SignatureOutOfDate                          = $True
                            RtpEnabled                                  = $True
                            AntivirusRequired                           = $True
                            AntiSpywareRequired                         = $True
                            DeviceThreatProtectionEnabled               = $True
                            DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                            ConfigurationManagerComplianceRequired      = $False
                            TPMRequired                                 = $False
                            DeviceCompliancePolicyScript                = $null
                            ValidOperatingSystemBuildRanges             = @()
                            RoleScopeTagIds                             = '0'
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

            It 'Should remove the iOS Device Compliance Policy from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceCompliancePolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceCompliancePolicy -MockWith {
                    return @{
                        DisplayName          = 'Windows 10 DSC Policy'
                        Description          = 'Test policy'
                        Id                   = 'f38b283d-d893-4c33-b6d2-d3bcb5f2dcc2'
                        AdditionalProperties = @{
                            '@odata.type'                               = '#microsoft.graph.windows10CompliancePolicy'
                            PasswordRequired                            = $False
                            PasswordBlockSimple                         = $False
                            PasswordRequiredToUnlockFromIdle            = $True
                            PasswordMinutesOfInactivityBeforeLock       = 15
                            PasswordExpirationDays                      = 365
                            PasswordMinimumLength                       = 6
                            PasswordPreviousPasswordBlockCount          = 13
                            PasswordMinimumCharacterSetCount            = 1
                            PasswordRequiredType                        = 'Devicedefault'
                            RequireHealthyDeviceReport                  = $True
                            OsMinimumVersion                            = 10
                            OsMaximumVersion                            = 10.19
                            MobileOsMinimumVersion                      = 10
                            MobileOsMaximumVersion                      = 10.19
                            EarlyLaunchAntiMalwareDriverEnabled         = $False
                            BitLockerEnabled                            = $False
                            SecureBootEnabled                           = $True
                            CodeIntegrityEnabled                        = $True
                            StorageRequireEncryption                    = $True
                            ActiveFirewallRequired                      = $True
                            DefenderEnabled                             = $True
                            DefenderVersion                             = ''
                            SignatureOutOfDate                          = $True
                            RtpEnabled                                  = $True
                            AntivirusRequired                           = $True
                            AntiSpywareRequired                         = $True
                            DeviceThreatProtectionEnabled               = $True
                            DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
                            ConfigurationManagerComplianceRequired      = $False
                            TPMRequired                                 = $False
                            DeviceCompliancePolicyScript                = $null
                            ValidOperatingSystemBuildRanges             = @()
                            RoleScopeTagIds                             = '0'
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
