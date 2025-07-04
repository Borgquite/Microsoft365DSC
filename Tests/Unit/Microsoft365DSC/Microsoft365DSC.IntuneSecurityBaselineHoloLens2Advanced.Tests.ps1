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
    -DscResource "IntuneSecurityBaselineHoloLens2Advanced" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = '9d0f07ef-5eef-4fd3-b95d-f9efbba07d23_1'
                    }
                }
            }
            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }
            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_mixedreality_aadgroupmembershipcachevalidityindays'
                                Name = 'AADGroupMembershipCacheValidityInDays'
                                OffsetUri = '/Config/MixedReality/AADGroupMembershipCacheValidityInDays'
                                AdditionalProperties = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                }
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_mixedreality_aadgroupmembershipcachevalidityindays'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '91dfa858-3c3a-4879-ade3-ae0083a619ab'
                            }
                            AdditionalProperties = @{
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                simpleSettingValue = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                    value = 7
                                }
                            }
                         }
                    },
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~passwordmanager_passwordmanagerenabled'
                                Name = 'PasswordManagerEnabled'
                                OffsetUri = '/Config/microsoft_edge~Policy~microsoft_edge~PasswordManager/PasswordManagerEnabled'
                                AdditionalProperties = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                    options = @(
                                        @{
                                            name ='Disabled'
                                            itemId = 'device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~passwordmanager_passwordmanagerenabled_0'
                                        }
                                    )
                                }
                            }
                        )
                        SettingInstance = @{
                            AdditionalProperties = @{
                                '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                choiceSettingValue = @{
                                    children = @()
                                    value = "device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~passwordmanager_passwordmanagerenabled_0"
                                }
                            }
                            SettingDefinitionId = 'device_vendor_msft_policy_config_microsoft_edge~policy~microsoft_edge~passwordmanager_passwordmanagerenabled'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'b76b9622-3c4e-4e07-9436-b14d4a5b326f'
                            }
                        }
                    },
                    @{
                        Id = '2'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_power_displayofftimeoutpluggedin'
                                Name = 'VideoPowerDownTimeOutAC_2'
                                OffsetUri = '/Config/Power/DisplayOffTimeoutPluggedIn'
                                AdditionalProperties = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                    options = @(
                                        @{
                                            name ='Enabled'
                                            itemId = 'device_vendor_msft_policy_config_power_displayofftimeoutpluggedin_1'
                                        }
                                    )
                                }
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_power_displayofftimeoutpluggedin'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'bb55ad43-b5cc-4d70-9f39-e24ce7c32f4a'
                            }
                            AdditionalProperties = @{
                               '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                choiceSettingValue = @{
                                    children = @()
                                    value = "device_vendor_msft_policy_config_power_displayofftimeoutpluggedin_1"
                                }
                            }
                        }
                    }
                )
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
                return @(@{
                    Id       = '12345-12345-12345-12345-12345'
                    Source   = 'direct'
                    SourceId = '12345-12345-12345-12345-12345'
                    Target   = @{
                        DeviceAndAppManagementAssignmentFilterId   = '12345-12345-12345-12345-12345'
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        AdditionalProperties                       = @(
                            @{
                                '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                                groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            }
                        )
                    }
                })
            }
        }

        # Test contexts
        Context -Name "The IntuneSecurityBaselineHoloLens2Advanced should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AADGroupMembershipCacheValidityInDays = 7;
                    Assignments = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_DeviceManagementConfigurationPolicyAssignments -Property @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        } -ClientOnly)
                    )
                    Description = "My Test"
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    PasswordManagerEnabled = "0";
                    VideoPowerDownTimeOutAC_2 = "1";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneSecurityBaselineHoloLens2Advanced exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AADGroupMembershipCacheValidityInDays = 7;
                    Assignments = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_DeviceManagementConfigurationPolicyAssignments -Property @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        } -ClientOnly)
                    )
                    Description = "My Test"
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    PasswordManagerEnabled = "0";
                    VideoPowerDownTimeOutAC_2 = "1";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneSecurityBaselineHoloLens2Advanced Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AADGroupMembershipCacheValidityInDays = 7;
                    Assignments = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_DeviceManagementConfigurationPolicyAssignments -Property @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        } -ClientOnly)
                    )
                    Description = "My Test"
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    PasswordManagerEnabled = "0";
                    VideoPowerDownTimeOutAC_2 = "1";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "The IntuneSecurityBaselineHoloLens2Advanced exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AADGroupMembershipCacheValidityInDays = 8; # Drift
                    Assignments = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_DeviceManagementConfigurationPolicyAssignments -Property @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        } -ClientOnly)
                    )
                    Description = "My Test"
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    PasswordManagerEnabled = "0";
                    VideoPowerDownTimeOutAC_2 = "1";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should call the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
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
