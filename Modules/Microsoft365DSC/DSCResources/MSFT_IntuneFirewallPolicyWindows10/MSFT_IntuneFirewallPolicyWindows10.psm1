function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.String]
        $CRLcheck,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DisableStatefulFtp,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.Int32[]]
        $EnablePacketQueue,

        [Parameter()]
        [ValidateSet('0', '1', '2', '4', '8')]
        [System.Int32[]]
        $IPsecExempt,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $OpportunisticallyMatchAuthSetPerKM,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PresharedKeyEncoding,

        [Parameter()]
        [ValidateRange(300, 3600)]
        [System.Int32]
        $SaIdleTime,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $DomainProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_Shielded,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $DomainProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PrivateProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PrivateProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PublicProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PublicProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformConnection,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformPacketDrop,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String[]]
        $AllowedTlsAuthenticationEndpoints,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $ConfiguredTlsAuthenticationNetworkName,

        [Parameter()]
        [ValidateSet('wsl')]
        [System.String]
        $Target,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $EnableLoopback,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AllowHostPolicyMerge,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Getting configuration of the Intune Firewall Policy for Windows10 with Id {$Id} and Name {$DisplayName}."

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
            $CommandName = $MyInvocation.MyCommand
            $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
                -CommandName $CommandName `
                -Parameters $PSBoundParameters
            Add-M365DSCTelemetryEvent -Data $data
            #endregion

            $nullResult = $PSBoundParameters
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            #region resource generator code
            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $Id -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Firewall Policy for Windows10 with Id {$Id}"

                if (-not [System.String]::IsNullOrEmpty($DisplayName))
                {
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                        -All `
                        -Filter "Name eq '$($DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue

                    if ($getValue.Length -gt 1)
                    {
                        throw "Duplicate Intune Firewall Policy for Windows10 named $DisplayName exist in tenant"
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Firewall Policy for Windows10 with Name {$DisplayName}."
                return $nullResult
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }
        $Id = $getValue.Id
        Write-Verbose -Message "An Intune Firewall Policy for Windows10 with Id {$Id} and Name {$DisplayName} was found"

        # Retrieve policy specific settings
        [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
            -All `
            -DeviceManagementConfigurationPolicyId $Id `
            -ExpandProperty 'settingDefinitions' `
            -ErrorAction Stop
        $policyTemplateId = $getValue.TemplateReference.TemplateId
        [array]$settingDefinitions = Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate `
            -DeviceManagementConfigurationPolicyTemplateId $policyTemplateId `
            -ExpandProperty 'settingDefinitions' `
            -All `
            -ErrorAction Stop | Select-Object -ExpandProperty SettingDefinitions

        $policySettings = @{}
        $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -AllSettingDefinitions $settingDefinitions

        $results = @{
            #region resource generator code
            Description           = $getValue.Description
            DisplayName           = $getValue.Name
            RoleScopeTagIds       = $getValue.RoleScopeTagIds
            Id                    = $getValue.Id
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            #endregion
        }
        $results += $policySettings

        $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $Id
        $assignmentResult = @()
        if ($assignmentsValues.Count -gt 0)
        {
            $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
        }
        $results.Add('Assignments', $assignmentResult)

        return [System.Collections.Hashtable] $results
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        # Necessary to rethrow caught exception regarding duplicate policies
        if ($_.Exception.Message -like "Duplicate*")
        {
            throw $_
        }

        return $nullResult
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.String]
        $CRLcheck,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DisableStatefulFtp,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.Int32[]]
        $EnablePacketQueue,

        [Parameter()]
        [ValidateSet('0', '1', '2', '4', '8')]
        [System.Int32[]]
        $IPsecExempt,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $OpportunisticallyMatchAuthSetPerKM,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PresharedKeyEncoding,

        [Parameter()]
        [ValidateRange(300, 3600)]
        [System.Int32]
        $SaIdleTime,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $DomainProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_Shielded,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $DomainProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PrivateProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PrivateProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PublicProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PublicProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformConnection,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformPacketDrop,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String[]]
        $AllowedTlsAuthenticationEndpoints,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $ConfiguredTlsAuthenticationNetworkName,

        [Parameter()]
        [ValidateSet('wsl')]
        [System.String]
        $Target,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $EnableLoopback,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AllowHostPolicyMerge,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion
        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentInstance = Get-TargetResource @PSBoundParameters

    $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    $templateReferenceId = '6078910e-d808-4a9f-a51d-1b8a7bacb7c0_1'
    $platforms = 'windows10'
    $technologies = 'mdm,microsoftSense'

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Firewall Policy for Windows10 with Name {$DisplayName}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $settings = Get-IntuneSettingCatalogPolicySetting `
            -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
            -TemplateId $templateReferenceId

        $createParameters = @{
            Name              = $DisplayName
            Description       = $Description
            TemplateReference = @{ templateId = $templateReferenceId }
            Platforms         = $platforms
            Technologies      = $technologies
            Settings          = $settings
        }

        #region resource generator code
        $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

        if ($policy.Id)
        {
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Intune Firewall Policy for Windows10 with Id {$($currentInstance.Id)}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $settings = Get-IntuneSettingCatalogPolicySetting `
            -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
            -TemplateId $templateReferenceId

        Update-IntuneDeviceConfigurationPolicy `
            -DeviceConfigurationPolicyId $currentInstance.Id `
            -Name $DisplayName `
            -Description $Description `
            -TemplateReferenceId $templateReferenceId `
            -Platforms $platforms `
            -Technologies $technologies `
            -Settings $settings

        #region resource generator code
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment `
            -DeviceConfigurationPolicyId $currentInstance.Id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/configurationPolicies'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing the Intune Firewall Policy for Windows10 with Id {$($currentInstance.Id)}"
        #region resource generator code
        Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
        #endregion
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.String]
        $CRLcheck,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DisableStatefulFtp,

        [Parameter()]
        [ValidateSet('0', '1', '2')]
        [System.Int32[]]
        $EnablePacketQueue,

        [Parameter()]
        [ValidateSet('0', '1', '2', '4', '8')]
        [System.Int32[]]
        $IPsecExempt,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $OpportunisticallyMatchAuthSetPerKM,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PresharedKeyEncoding,

        [Parameter()]
        [ValidateRange(300, 3600)]
        [System.Int32]
        $SaIdleTime,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $DomainProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_Shielded,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $DomainProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $DomainProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PrivateProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PrivateProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PrivateProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableInboundNotifications,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthModeIpsecSecuredPacketExemption,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_Shielded,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AuthAppsAllowUserPrefMerge,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $PublicProfile_LogFilePath,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableUnicastResponsesToMulticastBroadcast,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_GlobalPortsAllowUserPrefMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogSuccessConnections,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_AllowLocalIpsecPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogDroppedPackets,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_EnableLogIgnoredRules,

        [Parameter()]
        [ValidateRange(0, 4294967295)]
        [System.Int32]
        $PublicProfile_LogMaxFileSize,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $PublicProfile_DisableStealthMode,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformConnection,

        [Parameter()]
        [ValidateSet('0', '1', '2', '3')]
        [System.String]
        $ObjectAccess_AuditFilteringPlatformPacketDrop,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String[]]
        $AllowedTlsAuthenticationEndpoints,

        [Parameter()]
        [ValidateLength(0, 87516)]
        [System.String]
        $ConfiguredTlsAuthenticationNetworkName,

        [Parameter()]
        [ValidateSet('wsl')]
        [System.String]
        $Target,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_DomainProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_DomainProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $EnableLoopback,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PublicProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PublicProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_EnableFirewall,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultOutboundAction,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_DefaultInboundAction,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $HyperVVMSettings_PrivateProfile_AllowLocalPolicyMerge,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AllowHostPolicyMerge,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message "Testing configuration of the Intune Firewall Policy for Windows10 with Id {$Id} and Name {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    [Hashtable]$ValuesToCheck = @{}
    $MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        if ($_.Key -notlike '*Variable' -or $_.Key -notin @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction'))
        {
            if ($null -ne $CurrentValues[$_.Key] -or $null -ne $PSBoundParameters[$_.Key])
            {
                $ValuesToCheck.Add($_.Key, $null)
                if (-not $PSBoundParameters.ContainsKey($_.Key))
                {
                    $PSBoundParameters.Add($_.Key, $null)
                }
            }
        }
    }
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $targetVariable = $CurrentValues.$key
        if ($null -ne $source -and $source.GetType().Name -like '*CimInstance*')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($targetVariable)

            if (-not $testResult)
            {
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck.Remove('Id') | Out-Null
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    if ($testResult)
    {
        $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
    }

    Write-Verbose -Message "Test-TargetResource returned $testResult"

    return $testResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $Filter,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        #region resource generator code
        $policyTemplateID = '6078910e-d808-4a9f-a51d-1b8a7bacb7c0_1'
        [array]$getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
            -Filter $Filter `
            -All `
            -ErrorAction Stop | Where-Object `
            -FilterScript {
            $_.TemplateReference.TemplateId -eq $policyTemplateID
        }
        #endregion

        $i = 1
        $dscContent = ''
        if ($getValue.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($config in $getValue)
        {
            $displayedKey = $config.Id
            if (-not [String]::IsNullOrEmpty($config.displayName))
            {
                $displayedKey = $config.displayName
            }
            elseif (-not [string]::IsNullOrEmpty($config.name))
            {
                $displayedKey = $config.name
            }
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
            $params = @{
                Id                    = $config.Id
                DisplayName           = $config.Name
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $config
            $Results = Get-TargetResource @Params

            if ($Results.Assignments)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                if ($complexTypeStringResult)
                {
                    $Results.Assignments = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Assignments') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Assignments')

            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        return $dscContent
    }
    catch
    {
        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

        New-M365DSCLogEntry -Message 'Error during Export:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return ''
    }
}

Export-ModuleMember -Function *-TargetResource
