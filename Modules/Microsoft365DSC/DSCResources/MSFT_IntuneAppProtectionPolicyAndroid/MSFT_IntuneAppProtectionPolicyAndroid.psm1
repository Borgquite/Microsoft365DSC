function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String[]]
        $AllowedAndroidDeviceModels,

        [Parameter()]
        [System.Int32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [System.Boolean]
        $BiometricAuthenticationBlocked,

        [Parameter()]
        [System.Int32]
        $BlockAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.Boolean]
        $ConnectToVpnOnLaunch,

        [Parameter()]
        [System.String]
        $CustomDialerAppDisplayName,

        [Parameter()]
        [System.String]
        $CustomDialerAppPackageId,

        [Parameter()]
        [System.Boolean]
        $DeviceLockRequired,

        [Parameter()]
        [System.Boolean]
        $FingerprintAndBiometricEnabled,

        [Parameter()]
        [System.Boolean]
        $KeyboardsRestricted,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppDisplayName,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppPackageId,

        [Parameter()]
        [System.String]
        $MinimumWipePatchVersion,

        [Parameter()]
        [System.Int32]
        $PreviousPinBlockCount,

        [Parameter()]
        [System.Int32]
        $WarnAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Int32]
        $WipeAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.String[]]
        $Alloweddataingestionlocations,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceManufacturerNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceModelNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetAppsVerificationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetDeviceAttestationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceLockNotSet,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [ValidateSet("allApps", "managedApps", "customApp", "blocked")]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [ValidateSet("notConfigured", "secured", "low", "medium", "high")]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [ValidateSet("allow", "blockOrganizationalData", "block")]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet("anyApp", "anyManagedApp", "specificApps", "blocked")]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [ValidateSet("none", "enabled")]
        [System.String]
        $RequiredAndroidSafetyNetAppsVerificationType,

        [Parameter()]
        [ValidateSet("none", "basicIntegrity", "basicIntegrityAndDeviceCertification")]
        [System.String]
        $RequiredAndroidSafetyNetDeviceAttestationType,

        [Parameter()]
        [ValidateSet("basic", "hardwareBacked")]
        [System.String]
        $RequiredAndroidSafetyNetEvaluationType,

        [Parameter()]
        [ValidateSet("unspecified", "unmanaged", "mdm", "androidEnterprise", "androidEnterpriseDedicatedDevicesWithAzureAdSharedMode", "androidOpenSourceProjectUserAssociated", "androidOpenSourceProjectUserless", "unknownFutureValue")]
        [System.String]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ApprovedKeyboards,

        [Parameter()]
        [System.String[]]
        $ExemptedAppPackages,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $PeriodOnlineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $AllowedInboundDataTransferSources,

        [Parameter()]
        [System.String]
        $AllowedOutboundDataTransferDestinations,

        [Parameter()]
        [System.Boolean]
        $OrganizationalCredentialsRequired,

        [Parameter()]
        [System.String]
        $AllowedOutboundClipboardSharingLevel,

        [Parameter()]
        [System.Boolean]
        $DataBackupBlocked,

        [Parameter()]
        [System.Boolean]
        $DeviceComplianceRequired,

        [Parameter()]
        [System.Boolean]
        $ManagedBrowserToOpenLinksRequired,

        [Parameter()]
        [System.Boolean]
        $SaveAsBlocked,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeWipeIsEnforced,

        [Parameter()]
        [System.Boolean]
        $PinRequired,

        [Parameter()]
        [System.Boolean]
        $DisableAppPinIfDevicePinIsSet,

        [Parameter()]
        [System.UInt32]
        $MaximumPinRetries,

        [Parameter()]
        [System.Boolean]
        $SimplePinBlocked,

        [Parameter()]
        [System.UInt32]
        $MinimumPinLength,

        [Parameter()]
        [System.String]
        $PinCharacterSet,

        [Parameter()]
        [System.String[]]
        $AllowedDataStorageLocations,

        [Parameter()]
        [System.Boolean]
        $ContactSyncBlocked,

        [Parameter()]
        [System.String]
        $PeriodBeforePinReset,

        [Parameter()]
        [System.Boolean]
        $PrintBlocked,

        [Parameter()]
        [System.Boolean]
        $RequireClass3Biometrics,

        [Parameter()]
        [System.Boolean]
        $RequirePinAfterBiometricChange,

        [Parameter()]
        [System.Boolean]
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $DisableAppEncryptionIfDeviceEncryptionIsEnabled,

        [Parameter()]
        [System.String]
        $CustomBrowserDisplayName,

        [Parameter()]
        [System.String]
        $CustomBrowserPackageId,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [ValidateSet('allApps', 'allMicrosoftApps', 'allCoreMicrosoftApps', 'selectedPublicApps' )]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        [ValidateSet('notConfigured', 'microsoftEdge')]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredPatchVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningPatchVersion,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.Boolean]
        $ScreenCaptureBlocked,

        [Parameter()]
        [System.Boolean]
        $EncryptAppData,

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
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Getting configuration of the Intune Android App Protection Policy with Id {$Id} and DisplayName {$DisplayName}"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
            $CommandName = $MyInvocation.MyCommand
            $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
                -CommandName $CommandName `
                -Parameters $PSBoundParameters
            Add-M365DSCTelemetryEvent -Data $data
            #endregion

            $nullResult = $PSBoundParameters
            $nullResult.Ensure = 'Absent'

            $policyInfo = $null
            if (-not [string]::IsNullOrEmpty($Id))
            {
                Write-Verbose -Message "Searching for Policy using Id {$Id}"
                $policyInfo = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -Filter "Id eq '$Id'" -ExpandProperty Apps, assignments `
                    -ErrorAction SilentlyContinue
            }

            if ($null -eq $policyInfo)
            {
                if (-not [string]::IsNullOrEmpty($DisplayName))
                {
                    Write-Verbose -Message "Searching for Policy using DisplayName {$DisplayName}"
                    $policyInfoArray = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -ExpandProperty Apps, assignments `
                        -ErrorAction Stop -All:$true
                    $policyInfo = $policyInfoArray | Where-Object -FilterScript { $_.displayName -eq $DisplayName }
                }
            }

            if ($null -eq $policyInfo)
            {
                Write-Verbose -Message "No Android App Protection Policy {$DisplayName} was found"
                return $nullResult
            }

            # handle multiple results - throw error - may be able to remediate to specify ID in configuration at later date
            if ($policyInfo.GetType().IsArray)
            {
                Write-Verbose -Message "Multiple Android Policies with name {$DisplayName} were found - Where No valid ID is specified Module will only function with unique names, please manually remediate"
                $nullResult.Ensure = 'ERROR'
                throw 'Multiple Policies with same displayname identified - Module currently only functions with unique names'
            }

            Write-Verbose -Message "Found Android App Protection Policy {$DisplayName}"
        }
        else
        {
            $policyInfo = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -AndroidManagedAppProtectionId $Script:exportedInstance.Id -ExpandProperty Apps, assignments `
                -ErrorAction Stop
        }

        $appsArray = @()
        if ($null -ne $policyInfo.Apps)
        {
            foreach ($app in $policyInfo.Apps)
            {
                $appsArray += $app.MobileAppIdentifier.AdditionalProperties.packageId
            }
        }

        $assignmentsArray = @()
        $exclusionArray = @()
        if ($null -ne $policyInfo.Assignments)
        {
            foreach ($assignment in $policyInfo.Assignments)
            {
                $groupInfo = Get-MgGroup -GroupId $assignment.Target.AdditionalProperties.groupId -ErrorAction SilentlyContinue
                $groupValue = $assignment.Target.AdditionalProperties.groupId
                if ($null -ne $groupInfo)
                {
                    $groupValue = $groupInfo.DisplayName
                }

                switch ($assignment.Target.AdditionalProperties.'@odata.type')
                {
                    '#microsoft.graph.groupAssignmentTarget'
                    {

                        $assignmentsArray += $groupValue
                    }

                    '#microsoft.graph.exclusionGroupAssignmentTarget'
                    {
                        $exclusionArray += $groupValue
                    }
                }
            }
        }
        $Allparams = Get-InputParameters
        $policy = @{}

        #loop regular parameters and add from $polycyinfo
        foreach ($param in ($Allparams.Keys | Where-Object { $allparams.$_.Type -eq 'Parameter' }) )
        {
            # we need to process this because reverseDSC doesn't handle certain object types
            switch ($Allparams.$param.ExportFileType)
            {
                'String'
                {
                    if ($null -ne $policyInfo.$param)
                    {
                    $policy.Add($param, $policyInfo.$param.ToString())
                    }

                }

                'Array'
                {
                    if ($null -ne $policyInfo.$param)
                    {
                        $tmparray = @()
                        $policyInfo.$param | ForEach-Object { $tmparray += $_.ToString() }
                        $policy.Add($param, $tmparray)
                    }
                }

                DEFAULT
                {
                    if ($null -ne $policyInfo.$param)
                    {
                        $policy.Add($param, $policyInfo.$param)
                    }
                }
            }
        }
        # loop credential parameters and add them from input params
        foreach ($param in ($Allparams.Keys | Where-Object { $allparams.$_.Type -eq 'Credential' }) )
        {
            $policy.Add($param, (Get-Variable -Name $param).value)
        }
        $policy.Add('RoleScopeTagIds', $policyInfo.RoleScopeTagIds)
        # fix for managed identity credential value
        $policy.Add('ManagedIdentity', $ManagedIdentity.IsPresent)
        # add complex parameters manually as they all have different requirements - potential to change in future
        $policy.Add('Ensure', 'Present')
        $policy.Add('Apps', $appsArray)
        $policy.Add('Assignments', $assignmentsArray)
        $policy.Add('ExcludedGroups', $exclusionArray)
        $policy.Add('AppGroupType', $policyInfo.AppGroupType.ToString())
        #managed browser settings - export as is, when re-applying function will correct
        $policy.Add('ManagedBrowser', $policyInfo.ManagedBrowser.ToString())
        $policy.Add('ManagedBrowserToOpenLinksRequired', $policyInfo.ManagedBrowserToOpenLinksRequired)
        $policy.Add('CustomBrowserDisplayName', $policyInfo.CustomBrowserDisplayName)
        $policy.Add('CustomBrowserPackageId', $policyInfo.CustomBrowserPackageId)
        $policy.Add('AccessTokens', $AccessTokens)

        #convert keyvaluepairs to array
        $approvedKeyboardArray = @()
        foreach ($keyboard in $policyInfo.approvedKeyboards)
        {
            $approvedKeyboardArray += $keyboard.Name + '|' + $keyboard.Value
        }
        $policy.ApprovedKeyboards = $approvedKeyboardArray

        $exemptedAppPackagesArray = @()
        foreach ($exemptedapppackage in $policyInfo.exemptedAppPackages)
        {
            $exemptedAppPackagesArray += $exemptedapppackage.Name + '|' + $exemptedapppackage.Value
        }
        $policy.ExemptedAppPackages = $exemptedAppPackagesArray

        return $policy
    }
    catch
    {
        Write-Verbose -Message $_
        if ($_.Exception.Message -eq 'Multiple Policies with same displayname identified - Module currently only functions with unique names')
        {
            throw $_
        }
        else
        {
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential

            return $nullResult
        }
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String[]]
        $AllowedAndroidDeviceModels,

        [Parameter()]
        [System.Int32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [System.Boolean]
        $BiometricAuthenticationBlocked,

        [Parameter()]
        [System.Int32]
        $BlockAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.Boolean]
        $ConnectToVpnOnLaunch,

        [Parameter()]
        [System.String]
        $CustomDialerAppDisplayName,

        [Parameter()]
        [System.String]
        $CustomDialerAppPackageId,

        [Parameter()]
        [System.Boolean]
        $DeviceLockRequired,

        [Parameter()]
        [System.Boolean]
        $FingerprintAndBiometricEnabled,

        [Parameter()]
        [System.Boolean]
        $KeyboardsRestricted,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppDisplayName,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppPackageId,

        [Parameter()]
        [System.String]
        $MinimumWipePatchVersion,

        [Parameter()]
        [System.Int32]
        $PreviousPinBlockCount,

        [Parameter()]
        [System.Int32]
        $WarnAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Int32]
        $WipeAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.String[]]
        $Alloweddataingestionlocations,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceManufacturerNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceModelNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetAppsVerificationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetDeviceAttestationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceLockNotSet,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [ValidateSet("allApps", "managedApps", "customApp", "blocked")]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [ValidateSet("notConfigured", "secured", "low", "medium", "high")]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [ValidateSet("allow", "blockOrganizationalData", "block")]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet("anyApp", "anyManagedApp", "specificApps", "blocked")]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [ValidateSet("none", "enabled")]
        [System.String]
        $RequiredAndroidSafetyNetAppsVerificationType,

        [Parameter()]
        [ValidateSet("none", "basicIntegrity", "basicIntegrityAndDeviceCertification")]
        [System.String]
        $RequiredAndroidSafetyNetDeviceAttestationType,

        [Parameter()]
        [ValidateSet("basic", "hardwareBacked")]
        [System.String]
        $RequiredAndroidSafetyNetEvaluationType,

        [Parameter()]
        [ValidateSet("unspecified", "unmanaged", "mdm", "androidEnterprise", "androidEnterpriseDedicatedDevicesWithAzureAdSharedMode", "androidOpenSourceProjectUserAssociated", "androidOpenSourceProjectUserless", "unknownFutureValue")]
        [System.String]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ApprovedKeyboards,

        [Parameter()]
        [System.String[]]
        $ExemptedAppPackages,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $PeriodOnlineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $AllowedInboundDataTransferSources,

        [Parameter()]
        [System.String]
        $AllowedOutboundDataTransferDestinations,

        [Parameter()]
        [System.Boolean]
        $OrganizationalCredentialsRequired,

        [Parameter()]
        [System.String]
        $AllowedOutboundClipboardSharingLevel,

        [Parameter()]
        [System.Boolean]
        $DataBackupBlocked,

        [Parameter()]
        [System.Boolean]
        $DeviceComplianceRequired,

        [Parameter()]
        [System.Boolean]
        $ManagedBrowserToOpenLinksRequired,

        [Parameter()]
        [System.Boolean]
        $SaveAsBlocked,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeWipeIsEnforced,

        [Parameter()]
        [System.Boolean]
        $PinRequired,

        [Parameter()]
        [System.Boolean]
        $DisableAppPinIfDevicePinIsSet,

        [Parameter()]
        [System.UInt32]
        $MaximumPinRetries,

        [Parameter()]
        [System.Boolean]
        $SimplePinBlocked,

        [Parameter()]
        [System.UInt32]
        $MinimumPinLength,

        [Parameter()]
        [System.String]
        $PinCharacterSet,

        [Parameter()]
        [System.String[]]
        $AllowedDataStorageLocations,

        [Parameter()]
        [System.Boolean]
        $ContactSyncBlocked,

        [Parameter()]
        [System.String]
        $PeriodBeforePinReset,

        [Parameter()]
        [System.Boolean]
        $PrintBlocked,

        [Parameter()]
        [System.Boolean]
        $RequireClass3Biometrics,

        [Parameter()]
        [System.Boolean]
        $RequirePinAfterBiometricChange,

        [Parameter()]
        [System.Boolean]
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $DisableAppEncryptionIfDeviceEncryptionIsEnabled,

        [Parameter()]
        [System.String]
        $CustomBrowserDisplayName,

        [Parameter()]
        [System.String]
        $CustomBrowserPackageId,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [ValidateSet('allApps', 'allMicrosoftApps', 'allCoreMicrosoftApps', 'selectedPublicApps' )]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        [ValidateSet('notConfigured', 'microsoftEdge')]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredPatchVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningPatchVersion,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.Boolean]
        $ScreenCaptureBlocked,

        [Parameter()]
        [System.Boolean]
        $EncryptAppData,

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
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )
    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentPolicy = Get-TargetResource @PSBoundParameters

    if ($currentPolicy.Ensure -eq 'ERROR')
    {

        Throw 'Error when searching for current policy details - Please check verbose output for further detail'

    }
    if (($Ensure -eq 'Absent') -and ($currentPolicy.Ensure -eq 'Present'))
    {
        Write-Verbose -Message "Removing Android App Protection Policy {$DisplayName}"
        Remove-MgBetaDeviceAppManagementAndroidManagedAppProtection -AndroidManagedAppProtectionId $currentPolicy.id
        # then exit
        return
    }

    $setParams = @{}
    $assignmentsArray = @()
    $appsarray = @()

    $configstring = "`r`nConfiguration To Be Applied:`r`n"

    $Allparams = Get-InputParameters

    # loop through regular parameters
    foreach ($param in ($Allparams.keys | Where-Object { $allparams.$_.Type -eq 'Parameter' }) )
    {
        if ($PSBoundParameters.keys -contains $param )
        {
            switch ($Allparams.$param.ExportFileType)
            {
                'Duration'
                {
                    $setParams.Add($param, (Set-Timespan -duration $PSBoundParameters.$param))
                    $configstring += ($param + ':' + ($setParams.$param.ToString()) + "`r`n")
                }

                default
                {
                    $setParams.Add($param, $psboundparameters.$param)
                    $configstring += ($param + ':' + $setParams.$param + "`r`n")
                }
            }
        }
    }

    # handle complex parameters - manually for now
    if ($PSBoundParameters.Keys -contains 'Assignments' )
    {
        $PSBoundParameters.Assignments | ForEach-Object {
            if ($_ -ne $null)
            {
                $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($_ -replace "'", "''")'"
                $idValue = $_
                if (-not [System.String]::IsNullOrEmpty($groupInfo))
                {
                    $idValue = $groupInfo.Id
                }
                $assignmentsArray += set-JSONstring -id $idValue -type 'Assignments'
            }
        }
        $configstring += ( 'Assignments' + ":`r`n" + ($PSBoundParameters.Assignments | Out-String) + "`r`n" )
    }

    if ($PSBoundParameters.Keys -contains 'ExcludedGroups' )
    {
        $PSBoundParameters.ExcludedGroups | ForEach-Object {
            if ($_ -ne $null)
            {
                $assignmentsArray += set-JSONstring -id $_ -type 'ExcludedGroups'
            }
        }
        $configstring += ( 'ExcludedGroups' + ":`r`n" + ($PSBoundParameters.ExcludedGroups | Out-String) + "`r`n" )

    }

    #rebuild array as a MicrosoftGraphKeyValuePair hash table for ApprovedKeyboards
    if ($PSBoundParameters.keys -contains 'ApprovedKeyboards' )
    {
        $approvedKeyboardHastableArray = @()
        $PSBoundParameters.ApprovedKeyboards | ForEach-Object {
            if ($_ -ne $null)
            {
                $tempArray = @()
                $tempArray = $_ -split '[|]'
                $tempHash = @{}
                $tempHash.Add('name', $tempArray[0])
                $tempHash.Add('value', $tempArray[1])
                $approvedKeyboardHastableArray += $tempHash
            }
        }
        $configstring += ( 'ApprovedKeyboards' + ":`r`n" + ($PSBoundParameters.ApprovedKeyboards | Out-String) + "`r`n" )
        $setParams.ApprovedKeyboards = $approvedKeyboardHastableArray
    }

    #rebuild array as a MicrosoftGraphKeyValuePair hash table for ExemptedAppPackages
    if ($PSBoundParameters.Keys -contains 'ExemptedAppPackages' )
    {
        $exemptedAppPackagesHastableArray = @()
        $PSBoundParameters.ExemptedAppPackages | ForEach-Object {
            if ($_ -ne $null)
            {
                $tempArray = @()
                $tempArray = $_ -split '[|]'
                $tempHash = @{}
                $tempHash.Add('name', $tempArray[0])
                $tempHash.Add('value', $tempArray[1])
                $exemptedAppPackagesHastableArray += $tempHash
            }
        }
        $configstring += ( 'ExemptedAppPackages' + ":`r`n" + ($PSBoundParameters.ExemptedAppPackages | Out-String) + "`r`n" )
        $setParams.ExemptedAppPackages = $exemptedAppPackagesHastableArray
    }

    # set the apps values
    $AppsHash = set-AppsHash -AppGroupType $AppGroupType -apps $apps
    $appshash.Apps | ForEach-Object {
        if ($_ -ne $null)
        {
            $appsarray += set-JSONstring -id $_ -type 'Apps'
        }
    }
    $configstring += ('AppGroupType:' + $appshash.AppGroupType + "`r`n")
    $configstring += ('Apps' + ":`r`n" + ($appshash.Apps | Out-String) + "`r`n" )

    # Set the managedbrowser values
    $ManagedBrowserValuesHash = Set-ManagedBrowserValues @PSBoundParameters
    foreach ($param in $ManagedBrowserValuesHash.keys)
    {
        $setParams.Add($param, $ManagedBrowserValuesHash.$param)
        $configstring += ($param + ':' + $setParams.$param + "`r`n")
    }

    Write-Verbose -Message $configstring

    if (($Ensure -eq 'Present') -and ($currentPolicy.Ensure -eq 'Absent'))
    {
        Write-Verbose -Message "Creating new Android App Protection Policy {$DisplayName}"
        if ($id -ne '')
        {
            Write-Verbose -Message 'ID in Configuration Document will be ignored, Policy will be created with a new ID'
        }
        $setParams.Add('Assignments', $assignmentsArray)
        $newpolicy = New-MgBetaDeviceAppManagementAndroidManagedAppProtection @setParams
        $setParams.Add('AndroidManagedAppProtectionId', $newpolicy.Id)

    }
    elseif (($Ensure -eq 'Present') -and ($currentPolicy.Ensure -eq 'Present'))
    {
        Write-Verbose -Message "Updating existing Android App Protection Policy {$DisplayName}"
        if ( ($id -ne '') -and ( $id -ne $currentPolicy.id ) )
        {
            Write-Verbose -Message ("id in configuration document and returned policy do not match - updating policy with matching Displayname {$displayname} - ID {" + $currentPolicy.id + '}')
        }
        $setParams.add('AndroidManagedAppProtectionId', $currentPolicy.id)
        Update-MgBetaDeviceAppManagementAndroidManagedAppProtection @setParams

        Write-Verbose -Message "Setting Group Assignments with values:`r`n$(ConvertTo-Json $assignmentsArray -Depth 10)"
        Set-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -TargetedManagedAppConfigurationId $setParams.AndroidManagedAppProtectionId -Assignments $assignmentsArray

    }
    # now we need to set up the apps
    Write-Verbose -Message ('Setting Application values of type: ' + $AppsHash.AppGroupType)
    Invoke-MgBetaTargetDeviceAppManagementTargetedManagedAppConfigurationApp -TargetedManagedAppConfigurationId $setParams.AndroidManagedAppProtectionId -Apps $appsarray -AppGroupType $AppsHash.AppGroupType
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String[]]
        $AllowedAndroidDeviceModels,

        [Parameter()]
        [System.Int32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [System.Boolean]
        $BiometricAuthenticationBlocked,

        [Parameter()]
        [System.Int32]
        $BlockAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.Boolean]
        $ConnectToVpnOnLaunch,

        [Parameter()]
        [System.String]
        $CustomDialerAppDisplayName,

        [Parameter()]
        [System.String]
        $CustomDialerAppPackageId,

        [Parameter()]
        [System.Boolean]
        $DeviceLockRequired,

        [Parameter()]
        [System.Boolean]
        $FingerprintAndBiometricEnabled,

        [Parameter()]
        [System.Boolean]
        $KeyboardsRestricted,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppDisplayName,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppPackageId,

        [Parameter()]
        [System.String]
        $MinimumWipePatchVersion,

        [Parameter()]
        [System.Int32]
        $PreviousPinBlockCount,

        [Parameter()]
        [System.Int32]
        $WarnAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.Int32]
        $WipeAfterCompanyPortalUpdateDeferralInDays,

        [Parameter()]
        [System.String[]]
        $Alloweddataingestionlocations,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceManufacturerNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidDeviceModelNotAllowed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetAppsVerificationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfAndroidSafetyNetDeviceAttestationFailed,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfDeviceLockNotSet,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [System.String]
        [ValidateSet("block", "wipe", "warn", "blockWhenSettingIsSupported")]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [ValidateSet("allApps", "managedApps", "customApp", "blocked")]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [ValidateSet("notConfigured", "secured", "low", "medium", "high")]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [ValidateSet("allow", "blockOrganizationalData", "block")]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet("anyApp", "anyManagedApp", "specificApps", "blocked")]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [ValidateSet("none", "enabled")]
        [System.String]
        $RequiredAndroidSafetyNetAppsVerificationType,

        [Parameter()]
        [ValidateSet("none", "basicIntegrity", "basicIntegrityAndDeviceCertification")]
        [System.String]
        $RequiredAndroidSafetyNetDeviceAttestationType,

        [Parameter()]
        [ValidateSet("basic", "hardwareBacked")]
        [System.String]
        $RequiredAndroidSafetyNetEvaluationType,

        [Parameter()]
        [ValidateSet("unspecified", "unmanaged", "mdm", "androidEnterprise", "androidEnterpriseDedicatedDevicesWithAzureAdSharedMode", "androidOpenSourceProjectUserAssociated", "androidOpenSourceProjectUserless", "unknownFutureValue")]
        [System.String]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ApprovedKeyboards,

        [Parameter()]
        [System.String[]]
        $ExemptedAppPackages,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $PeriodOnlineBeforeAccessCheck,

        [Parameter()]
        [System.String]
        $AllowedInboundDataTransferSources,

        [Parameter()]
        [System.String]
        $AllowedOutboundDataTransferDestinations,

        [Parameter()]
        [System.Boolean]
        $OrganizationalCredentialsRequired,

        [Parameter()]
        [System.String]
        $AllowedOutboundClipboardSharingLevel,

        [Parameter()]
        [System.Boolean]
        $DataBackupBlocked,

        [Parameter()]
        [System.Boolean]
        $DeviceComplianceRequired,

        [Parameter()]
        [System.Boolean]
        $ManagedBrowserToOpenLinksRequired,

        [Parameter()]
        [System.Boolean]
        $SaveAsBlocked,

        [Parameter()]
        [System.String]
        $PeriodOfflineBeforeWipeIsEnforced,

        [Parameter()]
        [System.Boolean]
        $PinRequired,

        [Parameter()]
        [System.Boolean]
        $DisableAppPinIfDevicePinIsSet,

        [Parameter()]
        [System.UInt32]
        $MaximumPinRetries,

        [Parameter()]
        [System.Boolean]
        $SimplePinBlocked,

        [Parameter()]
        [System.UInt32]
        $MinimumPinLength,

        [Parameter()]
        [System.String]
        $PinCharacterSet,

        [Parameter()]
        [System.String[]]
        $AllowedDataStorageLocations,

        [Parameter()]
        [System.Boolean]
        $ContactSyncBlocked,

        [Parameter()]
        [System.String]
        $PeriodBeforePinReset,

        [Parameter()]
        [System.Boolean]
        $PrintBlocked,

        [Parameter()]
        [System.Boolean]
        $RequireClass3Biometrics,

        [Parameter()]
        [System.Boolean]
        $RequirePinAfterBiometricChange,

        [Parameter()]
        [System.Boolean]
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $DisableAppEncryptionIfDeviceEncryptionIsEnabled,

        [Parameter()]
        [System.String]
        $CustomBrowserDisplayName,

        [Parameter()]
        [System.String]
        $CustomBrowserPackageId,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [ValidateSet('allApps', 'allMicrosoftApps', 'allCoreMicrosoftApps', 'selectedPublicApps' )]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        [ValidateSet('notConfigured', 'microsoftEdge')]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredPatchVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningPatchVersion,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.Boolean]
        $ScreenCaptureBlocked,

        [Parameter()]
        [System.Boolean]
        $EncryptAppData,

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
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )
    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing configuration of Android App Protection Policy {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($CurrentValues.Ensure -eq 'ERROR')
    {
        throw 'Error when searching for current policy details - Please check verbose output for further detail'
    }

    if ($Ensure -eq 'Absent')
    {
        if ($currentvalues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Existing Policy {$DisplayName} will be removed"
            return $False
        }
        else
        {
            Write-Verbose -Message "Policy {$DisplayName} already removed"
            return $True
        }
    }

    if (($CurrentValues.Ensure -eq 'Absent') -and ($Ensure -eq 'Present'))
    {
        Write-Verbose -Message "Policy {$DisplayName} Not Present on tenant - New Policy will be created"
        return $false
    }

    $targetvalues = @{}

    $Allparams = get-InputParameters

    ($Allparams.keys | Where-Object { $allparams.$_.Type -eq 'Credential' }) | ForEach-Object {
        $CurrentValues.Remove($_) | Out-Null
    }

    # loop through regular parameters
    foreach ($param in ($Allparams.keys | Where-Object { $allparams.$_.Type -eq 'Parameter' }) )
    {
        if ($PSBoundParameters.keys -contains $param )
        {
            switch ($Allparams.$param.ExportFileType)
            {
                'Duration'
                {
                    $targetvalues.add($param, (set-TimeSpan -duration $PSBoundParameters.$param))
                }

                default
                {
                    $targetvalues.add($param, $psboundparameters.$param)
                }
            }
        }
        else
        {
            Write-Verbose -Message ('Unspecified Parameter in Config: ' + $param + '  Current Value Will be retained: ' + $CurrentValues.$param)
        }
    }
    Write-Verbose -Message 'Starting Assignments Check'
    # handle complex parameters - manually for now
    if ($PSBoundParameters.keys -contains 'Assignments' )
    {
        $assignmentsValue = @()
        foreach ($assignment in $Assignments)
        {
            $groupInfo = Get-MgGroup -GroupId $assignment -ErrorAction SilentlyContinue
            if ($null -ne $groupInfo)
            {
                $assignmentsValue += $groupInfo.DisplayName
            }
            else
            {
                $assignmentsValue += $assignment
            }
        }
        $targetvalues.add('Assignments', $assignmentsValue)
    }

    Write-Verbose -Message 'Starting Exluded Groups Check'
    if ($PSBoundParameters.keys -contains 'ExcludedGroups' )
    {
        $targetvalues.add('ExcludedGroups', $psboundparameters.ExcludedGroups)
    }

    # set the apps values
    Write-Verbose -Message "AppGroupType: $AppGroupType"
    Write-Verbose -Message "apps: $apps"
    $AppsHash = set-AppsHash -AppGroupType $AppGroupType -apps $apps
    $targetvalues.add('Apps', $AppsHash.Apps)
    $targetvalues.add('AppGroupType', $AppsHash.AppGroupType)
    # wipe out the current apps value if AppGroupType is anything but selectedpublicapps to match the appshash values
    if ($CurrentValues.AppGroupType -ne 'selectedPublicApps')
    {
        $CurrentValues.Apps = @()
    }

    # remove thre ID from the values to check as it may not match
    $targetvalues.remove('ID') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $targetvalues)"

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $targetvalues `
        -ValuesToCheck $targetvalues.Keys
    #-verbose

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        if (-not [string]::IsNullOrEmpty($Filter))
        {
            $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $Filter
            $Filter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $Filter
        }
        [array]$policies = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -All:$true -Filter $Filter -ErrorAction Stop
        $policies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $policies

        $i = 1
        $dscContent = ''
        if ($policies.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($policy in $policies)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.displayName)" -DeferWrite
            $params = @{
                Id                    = $policy.id
                DisplayName           = $policy.displayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationID         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
            $Results = Get-TargetResource @params

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
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
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like '*Request not applicable to target tenant*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
        }
        else
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            New-M365DSCLogEntry -Message 'Error during Export:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential
        }

        return ''
    }
}

function Set-JSONstring
{
    param
    (
        [string]$id,
        [string]$type
    )

    $JsonContent = ''

    switch ($type)
    {

        'Apps'
        {
            $JsonContent = @"
                    {
                    "id":"$($id)",
                    "mobileAppIdentifier": {
                        "@odata.type": "#microsoft.graph.AndroidMobileAppIdentifier",
                        "packageId": "$id"
                    }
                }
"@

        }
        'Assignments'
        {
            $JsonContent = @"
            {
            "id":"$($id)_incl",
            "target": {
                        "@odata.type": "#microsoft.graph.groupAssignmentTarget",
                        "groupId": "$($id)"
                    }
            }
"@
        }
        'ExcludedGroups'
        {
            $JsonContent = @"
            {
            "id":"$($id)_excl",
            "target": {
                        "@odata.type": "#microsoft.graph.exclusionGroupAssignmentTarget",
                        "groupId": "$($id)"
                    }
            }
"@

        }
    }

    return $JsonContent

}

function Set-Timespan
{
    param
    (
        [string]$duration
    )

    try
    {
        if ($duration.StartsWith('P'))
        {
            $timespan = [System.Xml.XmlConvert]::ToTimeSpan($duration)
        }
        else
        {
            $timespan = [TimeSpan]$duration
        }
    }
    catch
    {
        throw 'Problem converting input to a timespan - If configuration document is using iso8601 string (e.g. PT15M) try using new-timespan (e.g. new-timespan -minutes 15)'
    }

    return $timespan
}

function Set-AppsHash
{
    param
    (
        [string]$AppGroupType,
        [array]$Apps
    )

    if ($AppGroupType -eq '')
    {
        if ($apps.count -eq 0 )
        {
            $AppGroupType = 'allApps'
        }
        else
        {
            $AppGroupType = 'selectedPublicApps'
        }
        Write-Verbose -Message "setting AppGroupType to $AppGroupType"
    }

    $appsarray = @()
    if ($AppGroupType -eq 'selectedPublicApps' )
    {
        $appsarray = $apps
    }

    $AppsHash = @{
        'AppGroupType' = $AppGroupType
        'Apps'         = $appsarray
    }

    return $AppsHash
}

function Set-ManagedBrowserValues
{
    param
    (
        [string]$ManagedBrowser,
        [switch]$ManagedBrowserToOpenLinksRequired,
        [string]$CustomBrowserDisplayName,
        [string]$CustomBrowserPackageId
    )

    # via the gui there are only 3 possible configs:
    # edge - edge, true, empty id strings
    # any app - not configured, false, empty strings
    # unmanaged browser not configured, true, strings must not be empty
    if (!$ManagedBrowserToOpenLinksRequired)
    {
        $ManagedBrowser = 'notConfigured'
        $ManagedBrowserToOpenLinksRequired = $false
        $CustomBrowserDisplayName = ''
        $CustomBrowserPackageId = ''

    }
    else
    {
        if (($CustomBrowserDisplayName -ne '') -and ($CustomBrowserPackageId -ne ''))
        {
            $ManagedBrowser = 'notConfigured'
            $ManagedBrowserToOpenLinksRequired = $true
            $CustomBrowserDisplayName = $CustomBrowserDisplayName
            $CustomBrowserPackageId = $CustomBrowserPackageId
        }
        else
        {
            $ManagedBrowser = 'microsoftEdge'
            $ManagedBrowserToOpenLinksRequired = $true
            $CustomBrowserDisplayName = ''
            $CustomBrowserPackageId = ''
        }

    }

    $ManagedBrowserHash = @{
        'ManagedBrowser'                    = $ManagedBrowser
        'ManagedBrowserToOpenLinksRequired' = $ManagedBrowserToOpenLinksRequired
        'CustomBrowserDisplayName'          = $CustomBrowserDisplayName
        'CustomBrowserPackageId'            = $CustomBrowserPackageId
    }

    return $ManagedBrowserHash
}

function Get-InputParameters
{
    return @{
        AllowedDataStorageLocations                     = @{Type = 'Parameter'        ; ExportFileType = 'Array'; }
        AllowedInboundDataTransferSources               = @{Type = 'Parameter'        ; ExportFileType = 'String'; }
        AllowedOutboundClipboardSharingLevel            = @{Type = 'Parameter'        ; ExportFileType = 'String'; }
        AllowedOutboundDataTransferDestinations         = @{Type = 'Parameter'        ; ExportFileType = 'String'; }
        ApplicationId                                   = @{Type = 'Credential'       ; ExportFileType = 'NA'; }
        ApplicationSecret                               = @{Type = 'Credential'       ; ExportFileType = 'NA'; }
        AppGroupType                                    = @{Type = 'ComplexParameter' ; ExportFileType = 'String'; }
        Apps                                            = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        Assignments                                     = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        CertificateThumbprint                           = @{Type = 'Credential'       ; ExportFileType = 'NA'; }
        Managedidentity                                 = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        ContactSyncBlocked                              = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        Credential                                      = @{Type = 'Credential'       ; ExportFileType = 'NA'; }
        CustomBrowserDisplayName                        = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        CustomBrowserPackageId                          = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        DataBackupBlocked                               = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        Description                                     = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        DeviceComplianceRequired                        = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        DisableAppEncryptionIfDeviceEncryptionIsEnabled = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        DisableAppPinIfDevicePinIsSet                   = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        DisplayName                                     = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        EncryptAppData                                  = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        Ensure                                          = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        ExcludedGroups                                  = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        FingerprintBlocked                              = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        Id                                              = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        IsAssigned                                      = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        ManagedBrowser                                  = @{Type = 'ComplexParameter' ; ExportFileType = 'String'; }
        ManagedBrowserToOpenLinksRequired               = @{Type = 'ComplexParameter' ; ExportFileType = 'NA'; }
        MaximumPinRetries                               = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumPinLength                                = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumRequiredAppVersion                       = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumRequiredOSVersion                        = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumRequiredPatchVersion                     = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumWarningAppVersion                        = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumWarningOSVersion                         = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        MinimumWarningPatchVersion                      = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        OrganizationalCredentialsRequired               = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        PeriodBeforePinReset                            = @{Type = 'Parameter'        ; ExportFileType = 'Duration'; }
        PeriodOfflineBeforeAccessCheck                  = @{Type = 'Parameter'        ; ExportFileType = 'Duration'; }
        PeriodOfflineBeforeWipeIsEnforced               = @{Type = 'Parameter'        ; ExportFileType = 'Duration'; }
        PeriodOnlineBeforeAccessCheck                   = @{Type = 'Parameter'        ; ExportFileType = 'Duration'; }
        PinCharacterSet                                 = @{Type = 'Parameter'        ; ExportFileType = 'String'; }
        PinRequired                                     = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        PrintBlocked                                    = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        RequireClass3Biometrics                         = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        RequirePinAfterBiometricChange                  = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        SaveAsBlocked                                   = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        ScreenCaptureBlocked                            = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        SimplePinBlocked                                = @{Type = 'Parameter'        ; ExportFileType = 'NA'; }
        TenantId                                        = @{Type = 'Credential'       ; ExportFileType = 'NA'; }
        AllowedAndroidDeviceModels                         = @{Type = 'Parameter'; ExportFileType = 'Array'; }
        AllowedOutboundClipboardSharingExceptionLength     = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        BiometricAuthenticationBlocked                     = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        BlockAfterCompanyPortalUpdateDeferralInDays        = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        BlockDataIngestionIntoOrganizationDocuments        = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        ConnectToVpnOnLaunch                               = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        CustomDialerAppDisplayName                         = @{Type = 'Parameter'; ExportFileType = 'String'; }
        CustomDialerAppPackageId                           = @{Type = 'Parameter'; ExportFileType = 'String'; }
        DeviceLockRequired                                 = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        FingerprintAndBiometricEnabled                     = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        KeyboardsRestricted                                = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        MessagingRedirectAppDisplayName                    = @{Type = 'Parameter'; ExportFileType = 'String'; }
        MessagingRedirectAppPackageId                      = @{Type = 'Parameter'; ExportFileType = 'String'; }
        MinimumWipePatchVersion                            = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        PreviousPinBlockCount                              = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        WarnAfterCompanyPortalUpdateDeferralInDays         = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        WipeAfterCompanyPortalUpdateDeferralInDays         = @{Type = 'Parameter'; ExportFileType = 'NA'; }
        Alloweddataingestionlocations                      = @{Type = 'Parameter'; ExportFileType = 'Array'; }
        AppActionIfAndroidDeviceManufacturerNotAllowed     = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfAndroidDeviceModelNotAllowed            = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfAndroidSafetyNetAppsVerificationFailed  = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfAndroidSafetyNetDeviceAttestationFailed = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfDeviceComplianceRequired                = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfDeviceLockNotSet                        = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfMaximumPinRetriesExceeded               = @{Type = 'Parameter'; ExportFileType = 'String'; }
        AppActionIfUnableToAuthenticateUser                = @{Type = 'Parameter'; ExportFileType = 'String'; }
        MobileThreatDefenseRemediationAction               = @{Type = 'Parameter'; ExportFileType = 'String'; }
        DialerRestrictionLevel                             = @{Type = 'Parameter'; ExportFileType = 'String'; }
        MaximumAllowedDeviceThreatLevel                    = @{Type = 'Parameter'; ExportFileType = 'String'; }
        NotificationRestriction                            = @{Type = 'Parameter'; ExportFileType = 'String'; }
        ProtectedMessagingRedirectAppType                  = @{Type = 'Parameter'; ExportFileType = 'String'; }
        RequiredAndroidSafetyNetAppsVerificationType       = @{Type = 'Parameter'; ExportFileType = 'String'; }
        RequiredAndroidSafetyNetDeviceAttestationType      = @{Type = 'Parameter'; ExportFileType = 'String'; }
        RequiredAndroidSafetyNetEvaluationType             = @{Type = 'Parameter'; ExportFileType = 'String'; }
        TargetedAppManagementLevels                        = @{Type = 'Parameter'; ExportFileType = 'String'; }
        ApprovedKeyboards                                  = @{Type = 'Parameter'; ExportFileType = 'ComplexParameter'; }
        ExemptedAppPackages                                = @{Type = 'Parameter'; ExportFileType = 'ComplexParameter'; }
    }
}

Export-ModuleMember -Function *-TargetResource
