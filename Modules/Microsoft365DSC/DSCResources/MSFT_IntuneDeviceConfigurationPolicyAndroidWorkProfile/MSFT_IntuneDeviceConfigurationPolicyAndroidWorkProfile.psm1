function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $PasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $PasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $PasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $PasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $PasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $PasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $RequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowAppInstallsFromUnknownSources,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'preventAny', 'allowPersonalToWork', 'noRestrictions')]
        $WorkProfileDataSharingType,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockNotificationsWhileDeviceLocked,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockAddingAccounts,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBluetoothEnableContactSharing,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockScreenCapture,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCallerId,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCamera,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileContactsSearch,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCopyPaste,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'prompt', 'autoGrant', 'autoDeny')]
        $WorkProfileDefaultAppPermissionPolicy,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNumericCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNonLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLowerCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinUpperCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinSymbolCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $WorkProfilePasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $WorkProfileRequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileRequirePassword,

        [Parameter()]
        [System.Boolean]
        $SecurityRequireVerifyApps,

        [Parameter()]
        [System.String]
        $VpnAlwaysOnPackageIdentifier,

        [Parameter()]
        [System.Boolean]
        $VpnEnableAlwaysOnLockdownMode,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowWidgets,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockPersonalAppInstallsFromUnknownSources,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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

    Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy Android for Work Profile {$DisplayName}"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $M365DSCConnectionSplat = @{
                Workload          = 'MicrosoftGraph'
                InboundParameters = $PSBoundParameters
            }
            $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
            $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
            $data.Add('Resource', $ResourceName)
            $data.Add('Method', $MyInvocation.MyCommand)
            $data.Add('Principal', $Credential.UserName)
            $data.Add('TenantId', $TenantId)
            $data.Add('ConnectionMode', $ConnectionMode)
            Add-M365DSCTelemetryEvent -Data $data
            #endregion

            $nullResult = $PSBoundParameters
            $nullResult.Ensure = 'Absent'

            $policy = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                -ErrorAction Stop | Where-Object -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration' }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "No Intune Device Configuration Policy Android for Work Profile with {$DisplayName} was found"
                return $nullResult
            }
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        Write-Verbose -Message "An Intune Device Configuration Policy Android for Work Profile with {$DisplayName} was found"
        $results = @{
            Description                                               = $policy.Description
            DisplayName                                               = $policy.DisplayName
            RoleScopeTagIds                                           = $policy.RoleScopeTagIds
            PasswordBlockFaceUnlock                                   = $policy.AdditionalProperties.passwordBlockFaceUnlock
            PasswordBlockFingerprintUnlock                            = $policy.AdditionalProperties.passwordBlockFingerprintUnlock
            PasswordBlockIrisUnlock                                   = $policy.AdditionalProperties.passwordBlockIrisUnlock
            PasswordBlockTrustAgents                                  = $policy.AdditionalProperties.passwordBlockTrustAgents
            PasswordExpirationDays                                    = $policy.AdditionalProperties.passwordExpirationDays
            PasswordMinimumLength                                     = $policy.AdditionalProperties.passwordMinimumLength
            PasswordMinutesOfInactivityBeforeScreenTimeout            = $policy.AdditionalProperties.passwordMinutesOfInactivityBeforeScreenTimeout
            PasswordPreviousPasswordBlockCount                        = $policy.AdditionalProperties.passwordPreviousPasswordBlockCount
            PasswordSignInFailureCountBeforeFactoryReset              = $policy.AdditionalProperties.passwordSignInFailureCountBeforeFactoryReset
            PasswordRequiredType                                      = $policy.AdditionalProperties.passwordRequiredType
            RequiredPasswordComplexity                                = $policy.AdditionalProperties.requiredPasswordComplexity
            WorkProfileAllowAppInstallsFromUnknownSources             = $policy.AdditionalProperties.workProfileAllowAppInstallsFromUnknownSources
            WorkProfileDataSharingType                                = $policy.AdditionalProperties.workProfileDataSharingType
            WorkProfileBlockNotificationsWhileDeviceLocked            = $policy.AdditionalProperties.workProfileBlockNotificationsWhileDeviceLocked
            WorkProfileBlockAddingAccounts                            = $policy.AdditionalProperties.workProfileBlockAddingAccounts
            WorkProfileBluetoothEnableContactSharing                  = $policy.AdditionalProperties.workProfileBluetoothEnableContactSharing
            WorkProfileBlockScreenCapture                             = $policy.AdditionalProperties.workProfileBlockScreenCapture
            WorkProfileBlockCrossProfileCallerId                      = $policy.AdditionalProperties.workProfileBlockCrossProfileCallerId
            WorkProfileBlockCamera                                    = $policy.AdditionalProperties.workProfileBlockCamera
            WorkProfileBlockCrossProfileContactsSearch                = $policy.AdditionalProperties.workProfileBlockCrossProfileContactsSearch
            WorkProfileBlockCrossProfileCopyPaste                     = $policy.AdditionalProperties.workProfileBlockCrossProfileCopyPaste
            WorkProfileDefaultAppPermissionPolicy                     = $policy.AdditionalProperties.workProfileDefaultAppPermissionPolicy
            WorkProfilePasswordBlockFaceUnlock                        = $policy.AdditionalProperties.workProfilePasswordBlockFaceUnlock
            WorkProfilePasswordBlockFingerprintUnlock                 = $policy.AdditionalProperties.workProfilePasswordBlockFingerprintUnlock
            WorkProfilePasswordBlockIrisUnlock                        = $policy.AdditionalProperties.workProfilePasswordBlockIrisUnlock
            WorkProfilePasswordBlockTrustAgents                       = $policy.AdditionalProperties.workProfilePasswordBlockTrustAgents
            WorkProfilePasswordExpirationDays                         = $policy.AdditionalProperties.workProfilePasswordExpirationDays
            WorkProfilePasswordMinimumLength                          = $policy.AdditionalProperties.workProfilePasswordMinimumLength
            WorkProfilePasswordMinNumericCharacters                   = $policy.AdditionalProperties.workProfilePasswordMinNumericCharacters
            WorkProfilePasswordMinNonLetterCharacters                 = $policy.AdditionalProperties.workProfilePasswordMinNonLetterCharacters
            WorkProfilePasswordMinLetterCharacters                    = $policy.AdditionalProperties.workProfilePasswordMinLetterCharacters
            WorkProfilePasswordMinLowerCaseCharacters                 = $policy.AdditionalProperties.workProfilePasswordMinLowerCaseCharacters
            WorkProfilePasswordMinUpperCaseCharacters                 = $policy.AdditionalProperties.workProfilePasswordMinUpperCaseCharacters
            WorkProfilePasswordMinSymbolCharacters                    = $policy.AdditionalProperties.workProfilePasswordMinSymbolCharacters
            WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout = $policy.AdditionalProperties.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout
            WorkProfilePasswordPreviousPasswordBlockCount             = $policy.AdditionalProperties.workProfilePasswordPreviousPasswordBlockCount
            WorkProfilePasswordSignInFailureCountBeforeFactoryReset   = $policy.AdditionalProperties.workProfilePasswordSignInFailureCountBeforeFactoryReset
            WorkProfilePasswordRequiredType                           = $policy.AdditionalProperties.workProfilePasswordRequiredType
            WorkProfileRequiredPasswordComplexity                     = $policy.AdditionalProperties.workProfileRequiredPasswordComplexity
            WorkProfileRequirePassword                                = $policy.AdditionalProperties.workProfileRequirePassword
            SecurityRequireVerifyApps                                 = $policy.AdditionalProperties.securityRequireVerifyApps
            VpnAlwaysOnPackageIdentifier                              = $policy.AdditionalProperties.vpnAlwaysOnPackageIdentifier
            VpnEnableAlwaysOnLockdownMode                             = $policy.AdditionalProperties.vpnEnableAlwaysOnLockdownMode
            WorkProfileAllowWidgets                                   = $policy.AdditionalProperties.workProfileAllowWidgets
            WorkProfileBlockPersonalAppInstallsFromUnknownSources     = $policy.AdditionalProperties.workProfileBlockPersonalAppInstallsFromUnknownSources
            Ensure                                                    = 'Present'
            Credential                                                = $Credential
            ApplicationId                                             = $ApplicationId
            TenantId                                                  = $TenantId
            ApplicationSecret                                         = $ApplicationSecret
            CertificateThumbprint                                     = $CertificateThumbprint
            Managedidentity                                           = $ManagedIdentity.IsPresent
            AccessTokens                                              = $AccessTokens
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $policy.Id
        $assignmentResult = @()
        if ($assignmentsValues.Count -gt 0)
        {
            $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                -IncludeDeviceFilter:$true `
                -Assignments ($assignmentsValues)
        }
        $results.Add('Assignments', $assignmentResult)

        return $results
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $nullResult
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $PasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $PasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $PasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $PasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $PasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $PasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $RequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowAppInstallsFromUnknownSources,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'preventAny', 'allowPersonalToWork', 'noRestrictions')]
        $WorkProfileDataSharingType,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockNotificationsWhileDeviceLocked,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockAddingAccounts,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBluetoothEnableContactSharing,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockScreenCapture,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCallerId,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCamera,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileContactsSearch,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCopyPaste,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'prompt', 'autoGrant', 'autoDeny')]
        $WorkProfileDefaultAppPermissionPolicy,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNumericCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNonLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLowerCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinUpperCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinSymbolCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $WorkProfilePasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $WorkProfileRequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileRequirePassword,

        [Parameter()]
        [System.Boolean]
        $SecurityRequireVerifyApps,

        [Parameter()]
        [System.String]
        $VpnAlwaysOnPackageIdentifier,

        [Parameter()]
        [System.Boolean]
        $VpnEnableAlwaysOnLockdownMode,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowWidgets,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockPersonalAppInstallsFromUnknownSources,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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

    $M365DSCConnectionSplat = @{
        Workload          = 'MicrosoftGraph'
        InboundParameters = $PSBoundParameters
    }
    $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add('Resource', $ResourceName)
    $data.Add('Method', $MyInvocation.MyCommand)
    $data.Add('Principal', $Credential.UserName)
    $data.Add('TenantId', $TenantId)
    $data.Add('ConnectionMode', $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentPolicy = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove('Ensure') | Out-Null
    $PSBoundParameters.Remove('Credential') | Out-Null
    $PSBoundParameters.Remove('ApplicationId') | Out-Null
    $PSBoundParameters.Remove('TenantId') | Out-Null
    $PSBoundParameters.Remove('ApplicationSecret') | Out-Null
    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Device Configuration Policy {$DisplayName}"
        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $PSBoundParameters.Remove('Assignments') | Out-Null

        $AdditionalProperties = Get-M365DSCIntuneDeviceConfigurationPolicyAndroidWorkProfileAdditionalProperties -Properties ([System.Collections.Hashtable]$PSBoundParameters)
        $policy = New-MgBetaDeviceManagementDeviceConfiguration -DisplayName $DisplayName `
            -Description $Description `
            -AdditionalProperties $AdditionalProperties

        #region Assignments
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        if ($policy.id)
        {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing Device Configuration Policy {$DisplayName}"
        $configDevicePolicy = Get-MgBetaDeviceManagementDeviceConfiguration -Filter "DisplayName eq '$($Displayname -replace "'", "''")'" -ErrorAction SilentlyContinue | Where-Object `
            -FilterScript {
            $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration'
        }

        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $PSBoundParameters.Remove('Assignments') | Out-Null

        $AdditionalProperties = Get-M365DSCIntuneDeviceConfigurationPolicyAndroidWorkProfileAdditionalProperties -Properties ([System.Collections.Hashtable]$PSBoundParameters)
        Update-MgBetaDeviceManagementDeviceConfiguration -AdditionalProperties $AdditionalProperties `
            -Description $Description `
            -DeviceConfigurationId $configDevicePolicy.Id

        #region Assignments
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment `
            -DeviceConfigurationPolicyId $configDevicePolicy.id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/deviceConfigurations'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Device Configuration Policy {$DisplayName}"
        $configDevicePolicy = Get-MgBetaDeviceManagementDeviceConfiguration -Filter "DisplayName eq '$($Displayname -replace "'", "''")'" -ErrorAction SilentlyContinue | Where-Object `
            -FilterScript {
            $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration' `
        }

        Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $configDevicePolicy.Id
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $PasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $PasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $PasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $PasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $PasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $PasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $PasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $RequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowAppInstallsFromUnknownSources,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'preventAny', 'allowPersonalToWork', 'noRestrictions')]
        $WorkProfileDataSharingType,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockNotificationsWhileDeviceLocked,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockAddingAccounts,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBluetoothEnableContactSharing,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockScreenCapture,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCallerId,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCamera,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileContactsSearch,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockCrossProfileCopyPaste,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'prompt', 'autoGrant', 'autoDeny')]
        $WorkProfileDefaultAppPermissionPolicy,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFaceUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockFingerprintUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockIrisUnlock,

        [Parameter()]
        [System.Boolean]
        $WorkProfilePasswordBlockTrustAgents,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordExpirationDays,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinimumLength,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNumericCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinNonLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLetterCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinLowerCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinUpperCaseCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinSymbolCharacters,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordPreviousPasswordBlockCount,

        [Parameter()]
        [System.Int32]
        $WorkProfilePasswordSignInFailureCountBeforeFactoryReset,

        [Parameter()]
        [System.String]
        [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
        $WorkProfilePasswordRequiredType,

        [Parameter()]
        [System.String]
        [ValidateSet('none', 'low', 'medium', 'high')]
        $WorkProfileRequiredPasswordComplexity,

        [Parameter()]
        [System.Boolean]
        $WorkProfileRequirePassword,

        [Parameter()]
        [System.Boolean]
        $SecurityRequireVerifyApps,

        [Parameter()]
        [System.String]
        $VpnAlwaysOnPackageIdentifier,

        [Parameter()]
        [System.Boolean]
        $VpnEnableAlwaysOnLockdownMode,

        [Parameter()]
        [System.Boolean]
        $WorkProfileAllowWidgets,

        [Parameter()]
        [System.Boolean]
        $WorkProfileBlockPersonalAppInstallsFromUnknownSources,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add('Resource', $ResourceName)
    $data.Add('Method', $MyInvocation.MyCommand)
    $data.Add('Principal', $Credential.UserName)
    $data.Add('TenantId', $TenantId)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing configuration of Device Configuration Policy {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck
    $testResult = $true

    #region Assignments
    if ((-not $CurrentValues.Assignments) -xor (-not $ValuesToCheck.Assignments))
    {
        Write-Verbose -Message 'Configuration drift: one the assignment is null'
        return $false
    }

    if ($CurrentValues.Assignments)
    {
        $testResult = Compare-M365DSCIntunePolicyAssignment `
            -Source $CurrentValues.Assignments `
            -Target $ValuesToCheck.Assignments
    }

    if (-not $testResult)
    {
        return $false
    }
    $ValuesToCheck.Remove('Assignments') | Out-Null
    #endregion

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    if ($TestResult)
    {
        $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
    }

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

    $M365DSCConnectionSplat = @{
        Workload          = 'MicrosoftGraph'
        InboundParameters = $PSBoundParameters
    }
    $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add('Resource', $ResourceName)
    $data.Add('Method', $MyInvocation.MyCommand)
    $data.Add('Principal', $Credential.UserName)
    $data.Add('TenantId', $TenantId)
    $data.Add('ConnectionMode', $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        [array]$policies = Get-MgBetaDeviceManagementDeviceConfiguration `
            -ErrorAction Stop -All:$true -Filter $Filter | Where-Object `
            -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration' }
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

            Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.DisplayName)" -DeferWrite
            $params = @{
                DisplayName           = $policy.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
            $Results = Get-TargetResource @Params
            if ($Results.Assignments)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Assignments) -CIMInstanceName DeviceManagementConfigurationPolicyAssignments

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

function Get-M365DSCIntuneDeviceConfigurationPolicyAndroidWorkProfileAdditionalProperties
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties
    )

    $results = @{'@odata.type' = '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration' }
    foreach ($property in $properties.Keys)
    {
        if ($property -ne 'Verbose')
        {
            $propertyName = $property[0].ToString().ToLower() + $property.Substring(1, $property.Length - 1)
            $propertyValue = $properties.$property
            $results.Add($propertyName, $propertyValue)
        }
    }
    return $results
}

Export-ModuleMember -Function *-TargetResource
