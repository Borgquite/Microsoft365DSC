function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

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
        $AllowedDataIngestionLocations,

        [Parameter()]
        [System.Boolean]
        $AllowWidgetContentSync,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfAccountIsClockedOut,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [ValidateSet('selectedPublicApps', 'allCoreMicrosoftApps', 'allMicrosoftApps','allApps')]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.String]
        $CustomDialerAppProtocol,

        [Parameter()]
        [System.UInt32]
        $DeployedAppCount,

        [Parameter()]
        [ValidateSet('allApps','managedApps','customApp','blocked')]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [System.String[]]
        $ExemptedUniversalLinks,

        [Parameter()]
        [System.String]
        $GracePeriodToBlockAppsDuringOffClockHours,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.String[]]
        $ManagedUniversalLinks,

        [Parameter()]
        [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [System.String]
        $MaximumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWarningOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWipeOsVersion,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppUrlScheme,

        [Parameter()]
        [System.String]
        $MinimumWarningSdkVersion,

        [Parameter()]
        [ValidateSet('defenderOverThirdPartyPartner','thirdPartyPartnerOverDefender','unknownFutureValue')]
        [System.String]
        $MobileThreatDefensePartnerPriority,

        [Parameter()]
        [ValidateSet('block','wipe','warn','blockWhenSettingIsSupported')]
        [System.String]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [System.UInt32]
        $PreviousPinBlockCount,

        [Parameter()]
        [ValidateSet('anyApp','anyManagedApp','specificApps','blocked')]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [System.Boolean]
        $ThirdPartyKeyboardsBlocked,

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
        [System.String]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredSdkVersion,

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
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $FaceIdBlocked,

        [Parameter()]
        [ValidateSet('useDeviceSettings', 'afterDeviceRestart', 'whenDeviceLockedExceptOpenFiles', 'whenDeviceLocked')]
        [System.String]
        $AppDataEncryptionType,

        [Parameter()]
        [System.String]
        $MinimumWipeOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWipeAppVersion,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        $PinRequiredInsteadOfBiometricTimeout,

        [Parameter()]
        [System.Uint32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [ValidateSet('allow', 'blockOrganizationalData', 'block')]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise')]
        [System.String[]]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ExemptedAppProtocols,

        [Parameter()]
        [System.String]
        $MinimumWipeSdkVersion,

        [Parameter()]
        [System.String[]]
        $AllowedIosDeviceModels,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfIosDeviceModelNotAllowed,

        [Parameter()]
        [System.Boolean]
        $FilterOpenInToOnlyManagedApps,

        [Parameter()]
        [System.Boolean]
        $DisableProtectionOfManagedOutboundOpenInData,

        [Parameter()]
        [System.Boolean]
        $ProtectInboundDataFromUnknownSources,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        $CustomBrowserProtocol,

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

    Write-Verbose -Message "Getting configuration of the Intune iOS App Protection Policy with Id {$Identity} and DisplayName {$DisplayName}"

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

            if (-not [System.String]::IsNullOrEmpty($Identity))
            {
                [Array]$policy = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $Identity -ErrorAction SilentlyContinue
            }
            if ($policy.Length -eq 0)
            {
                Write-Verbose -Message "No iOS App Protection Policy {$Identity} was found by Identity. Trying to retrieve by DisplayName"
                [Array]$policy = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -All -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
            }

            if ($policy.Length -gt 1)
            {
                throw "Multiple policies with display name {$DisplayName} were found. Please ensure only one instance exists."
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "No iOS App Protection Policy {$DisplayName} was found by Display Name. Instance doesn't exist."
                return $nullResult
            }
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        Write-Verbose -Message "Found iOS App Protection Policy {$DisplayName}"

        $policyApps = Get-MgBetaDeviceAppManagementiOSManagedAppProtectionApp -IosManagedAppProtectionId $policy.Id

        $appsArray = @()
        foreach ($app in $policyApps)
        {
            $appsArray += $app.mobileAppIdentifier.additionalProperties.bundleId
        }

        $policyAssignments = Get-IntuneAppProtectionPolicyiOSAssignment -IosManagedAppProtectionId $policy.Id
        $assignmentsArray = @()
        $exclusionArray = @()
        $ObjectGuid = [System.Guid]::empty
        foreach ($policyAssignment in $policyAssignments)
        {
            $assignmentValue = $policyAssignment.target.groupId
            if ([System.Guid]::TryParse($policyAssignment.target.groupId, [System.Management.Automation.PSReference]$ObjectGuid))
            {
                $groupInfo = Get-MgGroup -GroupId $policyAssignment.target.groupId
                $assignmentValue = $groupInfo.DisplayName
            }
            if ($policyAssignment.target.'@odata.type' -eq '#microsoft.graph.groupAssignmentTarget')
            {
                $assignmentsArray += $assignmentValue
            }
            if ($policyAssignment.target.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget')
            {
                $exclusionArray += $assignmentValue
            }
        }

        $exemptedAppProtocolsArray = @()
        foreach ($exemptedAppProtocol in [Array]$policy.exemptedAppProtocols)
        {
            $exemptedAppProtocolsArray += ($exemptedAppProtocol.Name + ':' + $exemptedAppProtocol.Value)
        }

        $myPeriodOfflineBeforeAccessCheck = $policy.PeriodOfflineBeforeAccessCheck
        if ($null -ne $policy.PeriodOfflineBeforeAccessCheck)
        {
            $myPeriodOfflineBeforeAccessCheck = $policy.PeriodOfflineBeforeAccessCheck.ToString()
        }

        $myPeriodOnlineBeforeAccessCheck = $policy.PeriodOnlineBeforeAccessCheck
        if ($null -ne $policy.PeriodOnlineBeforeAccessCheck)
        {
            $myPeriodOnlineBeforeAccessCheck = $policy.PeriodOnlineBeforeAccessCheck.ToString()
        }

        $myPeriodOfflineBeforeWipeIsEnforced = $policy.PeriodOfflineBeforeWipeIsEnforced
        if ($null -ne $policy.PeriodOfflineBeforeWipeIsEnforced)
        {
            $myPeriodOfflineBeforeWipeIsEnforced = $policy.PeriodOfflineBeforeWipeIsEnforced.ToString()
        }

        $myPeriodBeforePinReset = $policy.PeriodBeforePinReset
        if ($null -ne $policy.PeriodBeforePinReset)
        {
            $myPeriodBeforePinReset = $policy.PeriodBeforePinReset.ToString()
        }

        $myPinRequiredInsteadOfBiometricTimeout = $policy.PinRequiredInsteadOfBiometricTimeout
        if ($null -ne $policy.PinRequiredInsteadOfBiometricTimeout)
        {
            $myPinRequiredInsteadOfBiometricTimeout = $policy.PinRequiredInsteadOfBiometricTimeout.ToString()
        }

        $myGracePeriodToBlockAppsDuringOffClockHours = $policy.gracePeriodToBlockAppsDuringOffClockHours
        if ($null -ne $policy.gracePeriodToBlockAppsDuringOffClockHours)
        {
            $myGracePeriodToBlockAppsDuringOffClockHours = $policy.gracePeriodToBlockAppsDuringOffClockHours.ToString()
        }

        $AllowedDataIngestionLocationsValue = @()
        if ($null -ne $policy.AllowedDataIngestionLocations)
        {
            $AllowedDataIngestionLocationsValue = [String[]]($policy.AllowedDataIngestionLocations)
        }

        $exemptedUniversalLinks = @()
        if ($null -ne $policy.exemptedUniversalLinks)
        {
            $exemptedUniversalLinks = [String[]]($policy.exemptedUniversalLinks)
        }

        $managedUniversalLinks = @()
        if ($null -ne $policy.managedUniversalLinks)
        {
            $managedUniversalLinks = [String[]]($policy.managedUniversalLinks)
        }

        $AllowedDataStorageLocations = @()
        if ($null -ne $policy.AllowedDataStorageLocations)
        {
            $AllowedDataStorageLocations = [String[]]($policy.AllowedDataStorageLocations)
        }

        return @{
            Identity                                       = $policy.Id
            DisplayName                                    = $policy.DisplayName
            Description                                    = $policy.Description
            RoleScopeTagIds                                = $policy.RoleScopeTagIds
            AllowedDataIngestionLocations                  = $AllowedDataIngestionLocationsValue
            AllowWidgetContentSync                         = $policy.AllowWidgetContentSync
            AppActionIfAccountIsClockedOut                 = [string]$policy.appActionIfAccountIsClockedOut
            AppActionIfUnableToAuthenticateUser            = [string]$policy.appActionIfUnableToAuthenticateUser
            AppGroupType                                   = [string]$policy.appGroupType
            BlockDataIngestionIntoOrganizationDocuments    = $policy.blockDataIngestionIntoOrganizationDocuments
            CustomDialerAppProtocol                        = [string]$policy.customDialerAppProtocol
            DeployedAppCount                               = $policy.deployedAppCount
            DialerRestrictionLevel                         = [string]$policy.dialerRestrictionLevel
            ExemptedUniversalLinks                         = $exemptedUniversalLinks
            GracePeriodToBlockAppsDuringOffClockHours      = $myGracePeriodToBlockAppsDuringOffClockHours
            IsAssigned                                     = $policy.isAssigned
            ManagedUniversalLinks                          = $managedUniversalLinks
            MaximumAllowedDeviceThreatLevel                = [string]$policy.maximumAllowedDeviceThreatLevel
            MaximumRequiredOsVersion                       = [string]$policy.maximumRequiredOsVersion
            MaximumWarningOsVersion                        = [string]$policy.maximumWarningOsVersion
            MaximumWipeOsVersion                           = [string]$policy.maximumWipeOsVersion
            MessagingRedirectAppUrlScheme                  = [string]$policy.messagingRedirectAppUrlScheme
            MinimumWarningSdkVersion                       = [string]$policy.minimumWarningSdkVersion
            MobileThreatDefensePartnerPriority             = [string]$policy.mobileThreatDefensePartnerPriority
            MobileThreatDefenseRemediationAction           = [string]$policy.mobileThreatDefenseRemediationAction
            PreviousPinBlockCount                          = $policy.previousPinBlockCount
            ProtectedMessagingRedirectAppType              = [string]$policy.protectedMessagingRedirectAppType
            thirdPartyKeyboardsBlocked                     = $policy.thirdPartyKeyboardsBlocked
            PeriodOfflineBeforeAccessCheck                 = $myPeriodOfflineBeforeAccessCheck
            PeriodOnlineBeforeAccessCheck                  = $myPeriodOnlineBeforeAccessCheck
            AllowedInboundDataTransferSources              = [String]$policy.AllowedInboundDataTransferSources
            AllowedOutboundDataTransferDestinations        = [String]$policy.AllowedOutboundDataTransferDestinations
            OrganizationalCredentialsRequired              = $policy.OrganizationalCredentialsRequired
            AllowedOutboundClipboardSharingLevel           = [String]$policy.AllowedOutboundClipboardSharingLevel
            DataBackupBlocked                              = $policy.DataBackupBlocked
            DeviceComplianceRequired                       = $policy.DeviceComplianceRequired
            ManagedBrowser                                 = [String]$policy.ManagedBrowser
            MinimumRequiredAppVersion                      = $policy.MinimumRequiredAppVersion
            MinimumRequiredOsVersion                       = $policy.MinimumRequiredOsVersion
            MinimumRequiredSdkVersion                      = $policy.MinimumRequiredSDKVersion
            MinimumWarningAppVersion                       = $policy.MinimumWarningAppVersion
            MinimumWarningOSVersion                        = $policy.MinimumWarningOSVersion
            ManagedBrowserToOpenLinksRequired              = $policy.ManagedBrowserToOpenLinksRequired
            SaveAsBlocked                                  = $policy.SaveAsBlocked
            PeriodOfflineBeforeWipeIsEnforced              = $myPeriodOfflineBeforeWipeIsEnforced
            PinRequired                                    = $policy.PinRequired
            DisableAppPinIfDevicePinIsSet                  = $policy.disableAppPinIfDevicePinIsSet
            MaximumPinRetries                              = $policy.MaximumPinRetries
            SimplePinBlocked                               = $policy.SimplePinBlocked
            MinimumPinLength                               = $policy.MinimumPinLength
            PinCharacterSet                                = [String]$policy.PinCharacterSet
            AllowedDataStorageLocations                    = $AllowedDataStorageLocations
            ContactSyncBlocked                             = $policy.ContactSyncBlocked
            PeriodBeforePinReset                           = $myPeriodBeforePinReset
            FaceIdBlocked                                  = $policy.FaceIdBlocked
            PrintBlocked                                   = $policy.PrintBlocked
            FingerprintBlocked                             = $policy.FingerprintBlocked
            AppDataEncryptionType                          = [String]$policy.AppDataEncryptionType
            Assignments                                    = $assignmentsArray
            ExcludedGroups                                 = $exclusionArray
            CustomBrowserProtocol                          = $policy.CustomBrowserProtocol
            Apps                                           = $appsArray
            MinimumWipeOSVersion                           = $policy.minimumWipeOSVersion
            MinimumWipeAppVersion                          = $policy.MinimumWipeAppVersion
            AppActionIfDeviceComplianceRequired            = [String]$policy.AppActionIfDeviceComplianceRequired
            AppActionIfMaximumPinRetriesExceeded           = [String]$policy.AppActionIfMaximumPinRetriesExceeded
            PinRequiredInsteadOfBiometricTimeout           = $myPinRequiredInsteadOfBiometricTimeout
            AllowedOutboundClipboardSharingExceptionLength = $policy.AllowedOutboundClipboardSharingExceptionLength
            NotificationRestriction                        = [String]$policy.NotificationRestriction
            TargetedAppManagementLevels                    = [String[]]$policy.TargetedAppManagementLevels.ToString().Split(',')
            ExemptedAppProtocols                           = $exemptedAppProtocolsArray
            MinimumWipeSdkVersion                          = $policy.MinimumWipeSdkVersion
            AllowedIosDeviceModels                         = $policy.AllowedIosDeviceModels
            AppActionIfIosDeviceModelNotAllowed            = [String]$policy.AppActionIfIosDeviceModelNotAllowed
            FilterOpenInToOnlyManagedApps                  = $policy.FilterOpenInToOnlyManagedApps
            DisableProtectionOfManagedOutboundOpenInData   = $policy.DisableProtectionOfManagedOutboundOpenInData
            ProtectInboundDataFromUnknownSources           = $policy.ProtectInboundDataFromUnknownSources
            Ensure                                         = 'Present'
            Credential                                     = $Credential
            ApplicationId                                  = $ApplicationId
            ApplicationSecret                              = $ApplicationSecret
            TenantId                                       = $TenantId
            CertificateThumbprint                          = $CertificateThumbprint
            Managedidentity                                = $ManagedIdentity.IsPresent
            AccessTokens                                   = $AccessTokens
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        if ($_.Exception.Message -eq "Multiple policies with display name {$DisplayName} were found. Please ensure only one instance exists.")
        {
            throw $_
        }
        else
        {
            return $nullResult
        }
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

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
        $AllowedDataIngestionLocations,

        [Parameter()]
        [System.Boolean]
        $AllowWidgetContentSync,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfAccountIsClockedOut,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [ValidateSet('selectedPublicApps', 'allCoreMicrosoftApps', 'allMicrosoftApps','allApps')]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.String]
        $CustomDialerAppProtocol,

        [Parameter()]
        [System.UInt32]
        $DeployedAppCount,

        [Parameter()]
        [ValidateSet('allApps','managedApps','customApp','blocked')]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [System.String[]]
        $ExemptedUniversalLinks,

        [Parameter()]
        [System.String]
        $GracePeriodToBlockAppsDuringOffClockHours,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.String[]]
        $ManagedUniversalLinks,

        [Parameter()]
        [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [System.String]
        $MaximumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWarningOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWipeOsVersion,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppUrlScheme,

        [Parameter()]
        [System.String]
        $MinimumWarningSdkVersion,

        [Parameter()]
        [ValidateSet('defenderOverThirdPartyPartner','thirdPartyPartnerOverDefender','unknownFutureValue')]
        [System.String]
        $MobileThreatDefensePartnerPriority,

        [Parameter()]
        [ValidateSet('block','wipe','warn','blockWhenSettingIsSupported')]
        [System.String]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [System.UInt32]
        $PreviousPinBlockCount,

        [Parameter()]
        [ValidateSet('anyApp','anyManagedApp','specificApps','blocked')]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [System.Boolean]
        $ThirdPartyKeyboardsBlocked,

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
        [System.String]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredSdkVersion,

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
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $FaceIdBlocked,

        [Parameter()]
        [ValidateSet('useDeviceSettings', 'afterDeviceRestart', 'whenDeviceLockedExceptOpenFiles', 'whenDeviceLocked')]
        [System.String]
        $AppDataEncryptionType,

        [Parameter()]
        [System.String]
        $MinimumWipeOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWipeAppVersion,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        $PinRequiredInsteadOfBiometricTimeout,

        [Parameter()]
        [System.Uint32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [ValidateSet('allow', 'blockOrganizationalData', 'block')]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise')]
        [System.String[]]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ExemptedAppProtocols,

        [Parameter()]
        [System.String]
        $MinimumWipeSdkVersion,

        [Parameter()]
        [System.String[]]
        $AllowedIosDeviceModels,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfIosDeviceModelNotAllowed,

        [Parameter()]
        [System.Boolean]
        $FilterOpenInToOnlyManagedApps,

        [Parameter()]
        [System.Boolean]
        $DisableProtectionOfManagedOutboundOpenInData,

        [Parameter()]
        [System.Boolean]
        $ProtectInboundDataFromUnknownSources,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        $CustomBrowserProtocol,

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
    $Identity = $currentPolicy.Identity

    $PSBoundParameters.Remove('Ensure') | Out-Null
    $PSBoundParameters.Remove('Credential') | Out-Null
    $PSBoundParameters.Remove('TenantId') | Out-Null
    $PSBoundParameters.Remove('ApplicationId') | Out-Null
    $PSBoundParameters.Remove('ApplicationSecret') | Out-Null
    $PSBoundParameters.Remove('CertificateThumbprint') | Out-Null
    $PSBoundParameters.Remove('ManagedIdentity') | Out-Null
    $PSBoundParameters.Remove('Verbose') | Out-Null
    $PSBoundParameters.Remove('AccessTokens') | Out-Null

    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new iOS App Protection Policy {$DisplayName}"
        $createParameters = ([Hashtable]$PSBoundParameters).Clone()
        $createParameters.Remove('Identity')
        $createParameters.Remove('Assignments')
        $createParameters.Remove('Apps')
        $createParameters.TargetedAppManagementLevels = $createParameters.TargetedAppManagementLevels -join ','

        $myApps = Get-IntuneAppProtectionPolicyiOSAppsToHashtable -Parameters $PSBoundParameters
        $myAssignments = Get-IntuneAppProtectionPolicyiOSAssignmentToHashtable -Parameters $PSBoundParameters

        $durationParameters = @(
            'PeriodOfflineBeforeAccessCheck'
            'PeriodOnlineBeforeAccessCheck'
            'PeriodOfflineBeforeWipeIsEnforced'
            'PeriodBeforePinReset'
            'PinRequiredInsteadOfBiometricTimeout'
            'GracePeriodToBlockAppsDuringOffClockHours'
        )
        foreach ($duration in $durationParameters)
        {
            if (-not [String]::IsNullOrEmpty($createParameters.$duration))
            {
                Write-Verbose -Message "Parsing {$($createParameters.$duration)} into TimeSpan"
                if ($createParameters.$duration.Startswith('P'))
                {
                    $timespan = [System.Xml.XmlConvert]::ToTimeSpan($createParameters.$duration)
                }
                else
                {
                    $timespan = [TimeSpan]$createParameters.$duration
                }
                $createParameters.$duration = $timespan
            }
        }
        $myExemptedAppProtocols = @()
        foreach ($exemptedAppProtocol in $ExemptedAppProtocols)
        {
            $myExemptedAppProtocols += @{
                Name  = $exemptedAppProtocol.Split(':')[0]
                Value = $exemptedAppProtocol.Split(':')[1]
            }
        }
        $createParameters.ExemptedAppProtocols = $myExemptedAppProtocols

        $arrayTemp = @("minimumWarningSdkVersion","maximumRequiredOsVersion","maximumWarningOsVersion","maximumWipeOsVersion")
        Foreach($item in $arrayTemp)
        {
                if ($createParameters.$item -eq "")
                {
                    $createParameters.Remove($item) #for some reason cmdlet can't handle this being blank, which is annoying as we can't enforce it
                }
        }

        $policy = New-MgBetaDeviceAppManagementiOSManagedAppProtection -BodyParameter $createParameters
        Update-IntuneAppProtectionPolicyiOSApp -IosManagedAppProtectionId $policy.id -Apps $myApps
        Write-Verbose -Message 'Updating policy assignments'
        Update-IntuneAppProtectionPolicyiOSAssignment -IosManagedAppProtectionId $policy.id -Assignments $myAssignments
    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing iOS App Protection Policy {$DisplayName}"
        $updateParameters = ([Hashtable]$PSBoundParameters).Clone()
        $updateParameters.Remove('Identity')
        $updateParameters.Remove('Assignments')
        $updateParameters.Remove('Apps')
        $updateParameters.TargetedAppManagementLevels = $updateParameters.TargetedAppManagementLevels -join ','

        $arrayTemp = @("minimumWarningSdkVersion","maximumRequiredOsVersion","maximumWarningOsVersion","maximumWipeOsVersion")
        Foreach($item in $arrayTemp)
        {
                if ($updateParameters.$item -eq "")
                {
                    $updateParameters.Remove($item) #for some reason cmdlet can't handle this being blank, which is annoying as we can't enforce it
                }
        }

        $myApps = Get-IntuneAppProtectionPolicyiOSAppsToHashtable -Parameters $PSBoundParameters
        $myAssignments = Get-IntuneAppProtectionPolicyiOSAssignmentToHashtable -Parameters $PSBoundParameters

        $durationParameters = @(
            'PeriodOfflineBeforeAccessCheck'
            'PeriodOnlineBeforeAccessCheck'
            'PeriodOfflineBeforeWipeIsEnforced'
            'PeriodBeforePinReset'
            'PinRequiredInsteadOfBiometricTimeout'
            'GracePeriodToBlockAppsDuringOffClockHours'
        )
        foreach ($duration in $durationParameters)
        {
            if (-not [String]::IsNullOrEmpty($updateParameters.$duration))
            {
                $updateParameters.$duration = [TimeSpan]::Parse($updateParameters.$duration)
            }
        }
        $myExemptedAppProtocols = @()
        foreach ($exemptedAppProtocol in $ExemptedAppProtocols)
        {
            $myExemptedAppProtocols += @{
                Name  = $exemptedAppProtocol.Split(':')[0]
                Value = $exemptedAppProtocol.Split(':')[1]
            }
        }
        $updateParameters.ExemptedAppProtocols = $myExemptedAppProtocols

        Update-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $Identity -BodyParameter $updateParameters
        Update-IntuneAppProtectionPolicyiOSApp -IosManagedAppProtectionId $Identity -Apps $myApps

        Write-Verbose -Message "Updating policy assignments: $myassignments"
        Update-IntuneAppProtectionPolicyiOSAssignment -IosManagedAppProtectionId $Identity -Assignments $myAssignments

    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing iOS App Protection Policy {$DisplayName}"
        Remove-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $Identity
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

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
        $AllowedDataIngestionLocations,

        [Parameter()]
        [System.Boolean]
        $AllowWidgetContentSync,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfAccountIsClockedOut,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
        [System.String]
        $AppActionIfUnableToAuthenticateUser,

        [Parameter()]
        [ValidateSet('selectedPublicApps', 'allCoreMicrosoftApps', 'allMicrosoftApps','allApps')]
        [System.String]
        $AppGroupType,

        [Parameter()]
        [System.Boolean]
        $BlockDataIngestionIntoOrganizationDocuments,

        [Parameter()]
        [System.String]
        $CustomDialerAppProtocol,

        [Parameter()]
        [System.UInt32]
        $DeployedAppCount,

        [Parameter()]
        [ValidateSet('allApps','managedApps','customApp','blocked')]
        [System.String]
        $DialerRestrictionLevel,

        [Parameter()]
        [System.String[]]
        $ExemptedUniversalLinks,

        [Parameter()]
        [System.String]
        $GracePeriodToBlockAppsDuringOffClockHours,

        [Parameter()]
        [System.Boolean]
        $IsAssigned,

        [Parameter()]
        [System.String[]]
        $ManagedUniversalLinks,

        [Parameter()]
        [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
        [System.String]
        $MaximumAllowedDeviceThreatLevel,

        [Parameter()]
        [System.String]
        $MaximumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWarningOsVersion,

        [Parameter()]
        [System.String]
        $MaximumWipeOsVersion,

        [Parameter()]
        [System.String]
        $MessagingRedirectAppUrlScheme,

        [Parameter()]
        [System.String]
        $MinimumWarningSdkVersion,

        [Parameter()]
        [ValidateSet('defenderOverThirdPartyPartner','thirdPartyPartnerOverDefender','unknownFutureValue')]
        [System.String]
        $MobileThreatDefensePartnerPriority,

        [Parameter()]
        [ValidateSet('block','wipe','warn','blockWhenSettingIsSupported')]
        [System.String]
        $MobileThreatDefenseRemediationAction,

        [Parameter()]
        [System.UInt32]
        $PreviousPinBlockCount,

        [Parameter()]
        [ValidateSet('anyApp','anyManagedApp','specificApps','blocked')]
        [System.String]
        $ProtectedMessagingRedirectAppType,

        [Parameter()]
        [System.Boolean]
        $ThirdPartyKeyboardsBlocked,

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
        [System.String]
        $ManagedBrowser,

        [Parameter()]
        [System.String]
        $MinimumRequiredAppVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningAppVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredOsVersion,

        [Parameter()]
        [System.String]
        $MinimumWarningOSVersion,

        [Parameter()]
        [System.String]
        $MinimumRequiredSdkVersion,

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
        $FingerprintBlocked,

        [Parameter()]
        [System.Boolean]
        $FaceIdBlocked,

        [Parameter()]
        [ValidateSet('useDeviceSettings', 'afterDeviceRestart', 'whenDeviceLockedExceptOpenFiles', 'whenDeviceLocked')]
        [System.String]
        $AppDataEncryptionType,

        [Parameter()]
        [System.String]
        $MinimumWipeOSVersion,

        [Parameter()]
        [System.String]
        $MinimumWipeAppVersion,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfDeviceComplianceRequired,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfMaximumPinRetriesExceeded,

        [Parameter()]
        [System.String]
        $PinRequiredInsteadOfBiometricTimeout,

        [Parameter()]
        [System.Uint32]
        $AllowedOutboundClipboardSharingExceptionLength,

        [Parameter()]
        [ValidateSet('allow', 'blockOrganizationalData', 'block')]
        [System.String]
        $NotificationRestriction,

        [Parameter()]
        [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise')]
        [System.String[]]
        $TargetedAppManagementLevels,

        [Parameter()]
        [System.String[]]
        $ExemptedAppProtocols,

        [Parameter()]
        [System.String]
        $MinimumWipeSdkVersion,

        [Parameter()]
        [System.String[]]
        $AllowedIosDeviceModels,

        [Parameter()]
        [ValidateSet('block', 'wipe', 'warn')]
        [System.String]
        $AppActionIfIosDeviceModelNotAllowed,

        [Parameter()]
        [System.Boolean]
        $FilterOpenInToOnlyManagedApps,

        [Parameter()]
        [System.Boolean]
        $DisableProtectionOfManagedOutboundOpenInData,

        [Parameter()]
        [System.Boolean]
        $ProtectInboundDataFromUnknownSources,

        [Parameter()]
        [System.String[]]
        $Apps,

        [Parameter()]
        [System.String[]]
        $Assignments,

        [Parameter()]
        [System.String[]]
        $ExcludedGroups,

        [Parameter()]
        [System.String]
        $CustomBrowserProtocol,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing configuration of iOS App Protection Policy {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $ValuesToCheck.Remove('Identity')

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

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

    #Ensure the proper dependencies are installed in the current environment
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
        [array]$policies = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -All:$true -Filter $Filter -ErrorAction Stop
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
                Identity              = $policy.id
                DisplayName           = $policy.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationID         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
            $Results = Get-TargetResource @Params

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

function Get-IntuneAppProtectionPolicyiOSAppsToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Parameters
    )

    $apps = @()
    foreach ($app in $Parameters.Apps)
    {
        $apps += @{
            id                  = $app + '.ios'
            mobileAppIdentifier = @{
                '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                bundleId      = $app
            }
        }
    }
    return @{apps = $apps }
}


function Get-IntuneAppProtectionPolicyiOSAssignmentToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Parameters
    )

    $ObjectGuid = [System.Guid]::empty
    $assignments = @()
    foreach ($assignment in $Parameters.Assignments)
    {
        $assignmentValue = $assignment
        if (-not [System.Guid]::TryParse($assignment, [System.Management.Automation.PSReference]$ObjectGuid))
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($assignment -replace "'", "''")'"
            $assignmentValue = $groupInfo.Id
        }
        $assignments += @{
            'target' = @{
                groupId       = $assignmentValue
                '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
            }
        }
    }
    foreach ($exclusion in $Parameters.Exclusions)
    {
        $assignmentValue = $exclusion
        if (-not [System.Guid]::TryParse($exclusion, [System.Management.Automation.PSReference]$ObjectGuid))
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($exclusion -replace "'", "''")'"
            $assignmentValue = $groupInfo.Id
        }
        $assignments += @{
            'target' = @{
                groupId       = $assignmentValue
                '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
            }
        }
    }

    return @{'assignments' = $assignments }
}
function Get-IntuneAppProtectionPolicyiOSAssignment
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $IosManagedAppProtectionId
    )

    try
    {
        $Url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceAppManagement/iosManagedAppProtections('$IosManagedAppProtectionId')/assignments"
        $response = Invoke-MgGraphRequest -Method Get `
            -Uri $Url
        return $response.value
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential
    }
    return $null
}

function Update-IntuneAppProtectionPolicyiOSAssignment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Assignments,

        [Parameter(Mandatory = $true)]
        [System.String]
        $IosManagedAppProtectionId
    )
    try
    {
        $Url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceAppManagement/iosManagedAppProtections('$IosManagedAppProtectionId')/assign"
        $body = ($Assignments | ConvertTo-Json -Depth 20 -Compress)
        Write-Verbose -Message "Group Assignment for iOS App Protection policy with JSON payload {$Url}: `r`n$body"
        Invoke-MgGraphRequest -Method POST `
            -Uri $Url `
            -Body $body `
            -Headers @{'Content-Type' = 'application/json' }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error updating data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential
    }
}

function Update-IntuneAppProtectionPolicyiOSApp
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Apps,

        [Parameter(Mandatory = $true)]
        [System.String]
        $IosManagedAppProtectionId
    )

    try
    {
        $Url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceAppManagement/iosManagedAppProtections('$IosManagedAppProtectionId')/targetApps"
        # Write-Verbose -Message "Group Assignment for iOS App Protection policy with JSON payload: `r`n$JSONContent"
        Invoke-MgGraphRequest -Method POST `
            -Uri $Url `
            -Body ($Apps | ConvertTo-Json -Depth 20) `
            -Headers @{'Content-Type' = 'application/json' } | Out-Null
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error updating data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential
    }
}

Export-ModuleMember -Function *-TargetResource
