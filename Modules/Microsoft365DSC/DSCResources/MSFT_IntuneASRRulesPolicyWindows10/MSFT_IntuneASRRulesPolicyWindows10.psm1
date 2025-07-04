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

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ProcessCreationType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode')]
        [System.String]
        $AdvancedRansomewareProtectionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode' , 'disable' in next breaking change, don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $BlockPersistenceThroughWmiType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptObfuscatedMacroCodeType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeMacroCodeAllowWin32ImportsType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsLaunchChildProcessType,

        # In next Breaking Change set it to 'notConfigured', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification')]
        [System.String]
        $GuardMyFoldersType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedUSBProcessType,

        [Parameter()]
        [System.String[]]
        $AttackSurfaceReductionExcludedPaths,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedExecutableType,

        # In next Breaking Change set it to 'notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeCommunicationAppsLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $EmailContentExecutionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptDownloadedPayloadExecutionType,

        [Parameter()]
        [System.String[]]
        $AdditionalGuardedFolders,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $AdobeReaderLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsExecutableContentCreationOrLaunchType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $PreventCredentialStealingType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsOtherProcessInjectionType,

        [Parameter()]
        [System.String[]]
        $GuardedFoldersAllowedAppPaths,

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

    Write-Verbose -Message "Getting configuration of the Intune Endpoint Protection Attack Surface Protection rules Policy with Id {$Identity} and DisplayName {$DisplayName}"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters `
                -ErrorAction Stop

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

            $policy = $null
            #Retrieve policy general settings
            if (-not [string]::IsNullOrEmpty($Identity))
            {
                $policy = Get-MgBetaDeviceManagementIntent -DeviceManagementIntentId $Identity -ErrorAction SilentlyContinue
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "No Endpoint Protection Attack Surface Protection rules Policy with identity {$Identity} was found"
                if (-not [String]::IsNullOrEmpty($DisplayName))
                {
                    $filter = "DisplayName eq '$($DisplayName -replace "'", "''")' and (TemplateId eq '0e237410-1367-4844-bd7f-15fb0f08943b')"
                    $policy = Get-MgBetaDeviceManagementIntent -All `
                                                               -Filter $filter -ErrorAction SilentlyContinue
                }

                if (([array]$policy).count -gt 1)
                {
                    throw "A policy with a duplicated displayName {'$DisplayName'} was found - Ensure displayName is unique"
                }
            }
            if ($null -eq $policy)
            {
                Write-Verbose -Message "No Endpoint Protection Attack Surface Protection rules Policy with displayName {$DisplayName} was found"
                return $nullResult
            }
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        #Retrieve policy specific settings
        [array]$settings = Get-MgBetaDeviceManagementIntentSetting `
            -DeviceManagementIntentId $policy.Id `
            -ErrorAction Stop

        $returnHashtable = @{}
        $returnHashtable.Add('Identity', $policy.Id)
        $returnHashtable.Add('DisplayName', $policy.DisplayName)
        $returnHashtable.Add('Description', $policy.Description)
        $returnHashtable.Add('RoleScopeTagIds', $policy.RoleScopeTagIds)

        foreach ($setting in $settings)
        {
            $settingName = $setting.definitionId.replace('deviceConfiguration--windows10EndpointProtectionConfiguration_defender', '')
            $settingValue = $setting.ValueJson | ConvertFrom-Json

            $returnHashtable.Add($settingName, $settingValue)
        }

        Write-Verbose -Message "Found Endpoint Protection Attack Surface Protection rules Policy {$DisplayName}"

        $returnHashtable.Add('Ensure', 'Present')
        $returnHashtable.Add('Credential', $Credential)
        $returnHashtable.Add('ApplicationId', $ApplicationId)
        $returnHashtable.Add('TenantId', $TenantId)
        $returnHashtable.Add('ApplicationSecret', $ApplicationSecret)
        $returnHashtable.Add('CertificateThumbprint', $CertificateThumbprint)
        $returnHashtable.Add('ManagedIdentity', $ManagedIdentity.IsPresent)
        $returnHashtable.Add('AccessTokens', $AccessTokens)

        $returnAssignments = @()
        $graphAssignments = Get-MgBetaDeviceManagementIntentAssignment -DeviceManagementIntentId $policy.Id
        if ($graphAssignments.count -gt 0)
        {
            $returnAssignments += ConvertFrom-IntunePolicyAssignment -Assignments $graphAssignments -IncludeDeviceFilter:$true
        }
        $returnHashtable.Add('Assignments', $returnAssignments)

        return $returnHashtable
    }
    catch
    {
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*')
        {
            if (Assert-M365DSCIsNonInteractiveShell)
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
        }
        else
        {
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential
        }

        return $nullResult
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

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ProcessCreationType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode')]
        [System.String]
        $AdvancedRansomewareProtectionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode' , 'disable' in next breaking change, don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $BlockPersistenceThroughWmiType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptObfuscatedMacroCodeType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeMacroCodeAllowWin32ImportsType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsLaunchChildProcessType,

        # In next Breaking Change set it to 'notConfigured', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification')]
        [System.String]
        $GuardMyFoldersType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedUSBProcessType,

        [Parameter()]
        [System.String[]]
        $AttackSurfaceReductionExcludedPaths,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedExecutableType,

        # In next Breaking Change set it to 'notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeCommunicationAppsLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $EmailContentExecutionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptDownloadedPayloadExecutionType,

        [Parameter()]
        [System.String[]]
        $AdditionalGuardedFolders,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $AdobeReaderLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsExecutableContentCreationOrLaunchType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $PreventCredentialStealingType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsOtherProcessInjectionType,

        [Parameter()]
        [System.String[]]
        $GuardedFoldersAllowedAppPaths,

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
    $PSBoundParameters.Remove('Ensure') | Out-Null
    $PSBoundParameters.Remove('Credential') | Out-Null
    $PSBoundParameters.Remove('ApplicationId') | Out-Null
    $PSBoundParameters.Remove('TenantId') | Out-Null
    $PSBoundParameters.Remove('ApplicationSecret') | Out-Null
    $PSBoundParameters.Remove('CertificateThumbprint') | Out-Null
    $PSBoundParameters.Remove('ManagedIdentity') | Out-Null
    $PSBoundParameters.Remove('AccessTokens') | Out-Null

    $IncorrectParameters = @{
        BlockPersistenceThroughWmiType                  = @('userDefined', 'warn')
        OfficeAppsOtherProcessInjectionType             = 'userDefined'
        OfficeAppsLaunchChildProcessType                = 'userDefined'
        OfficeAppsExecutableContentCreationOrLaunchType = 'userDefined'
        OfficeMacroCodeAllowWin32ImportsType            = 'userDefined'
        OfficeCommunicationAppsLaunchChildProcess       = 'disable'
        ScriptObfuscatedMacroCodeType                   = 'userDefined'
        ScriptDownloadedPayloadExecutionType            = @('userDefined', 'warn')
        ProcessCreationType                             = 'userDefined'
        UntrustedUSBProcessType                         = 'userDefined'
        UntrustedExecutableType                         = 'userDefined'
        EmailContentExecutionType                       = 'userDefined'
        GuardMyFoldersType                              = 'userDefined'
    }

    $ExceptionMessage = $null
    foreach ($Key in $PSBoundParameters.Keys)
    {
        $InvalidValue = $IncorrectParameters[$Key]
        if (![string]::IsNullOrEmpty($InvalidValue))
        {
            $Value = $PSBoundParameters.$Key
            if ($Value -in $InvalidValue)
            {
                $ExceptionMessage += "Property {0} set to invalid value {1}`n" -f $Key, $Value
            }
        }
    }

    if (![string]::IsNullOrEmpty($ExceptionMessage))
    {
        $ExceptionMessage += 'Please update your configuration.'
        Write-Verbose -Message $ExceptionMessage

        New-M365DSCLogEntry -Message $ExceptionMessage `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $null
    }

    $policyTemplateID = '0e237410-1367-4844-bd7f-15fb0f08943b'

    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Endpoint Protection Attack Surface Protection rules Policy {$DisplayName}"
        $PSBoundParameters.Remove('Identity') | Out-Null
        $PSBoundParameters.Remove('Assignments') | Out-Null
        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null

        $settings = Get-M365DSCIntuneDeviceConfigurationSettings `
            -Properties ([System.Collections.Hashtable]$PSBoundParameters) `
            -TemplateId $policyTemplateID

        $createParameters = @{}
        $createParameters.add('DisplayName', $DisplayName)
        $createParameters.add('Description', $Description)
        $createParameters.add('Settings', $settings)
        $createParameters.add('TemplateId', $policyTemplateID)
        $policy = New-MgBetaDeviceManagementIntent -BodyParameter $createParameters

        #region Assignments
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        if ($policy.id)
        {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/intents'
        }
        #endregion

    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing Endpoint Protection Attack Surface Protection rules Policy {$DisplayName}"

        $PSBoundParameters.Remove('Identity') | Out-Null
        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $PSBoundParameters.Remove('Assignments') | Out-Null

        $settings = Get-M365DSCIntuneDeviceConfigurationSettings `
            -Properties ([System.Collections.Hashtable]$PSBoundParameters) `
            -TemplateId $policyTemplateID

        $updateParameters = @{}
        $updateParameters.add('DisplayName', $DisplayName)
        $updateParameters.add('Description', $Description)
        Update-MgBetaDeviceManagementIntent -DeviceManagementIntentId $currentPolicy.Identity -BodyParameter $updateParameters

        #Update-MgBetaDeviceManagementIntent does not support updating the property settings
        #Update-MgBetaDeviceManagementIntentSetting only support updating a single setting at a time
        #Using Rest to reduce the number of calls
        $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/intents/$($currentPolicy.Identity)/updateSettings"
        $body = @{'settings' = $settings }
        Invoke-MgGraphRequest -Method POST -Uri $Uri -Body ($body | ConvertTo-Json -Depth 20) -ContentType 'application/json' 4> $null

        #region Assignments
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentPolicy.Identity `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/intents'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Endpoint Protection Attack Surface Protection rules Policy {$DisplayName}"
        Remove-MgBetaDeviceManagementIntent -DeviceManagementIntentId $currentPolicy.Identity -Confirm:$false
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

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ProcessCreationType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode')]
        [System.String]
        $AdvancedRansomewareProtectionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode' , 'disable' in next breaking change, don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $BlockPersistenceThroughWmiType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptObfuscatedMacroCodeType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeMacroCodeAllowWin32ImportsType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsLaunchChildProcessType,

        # In next Breaking Change set it to 'notConfigured', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification')]
        [System.String]
        $GuardMyFoldersType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedUSBProcessType,

        [Parameter()]
        [System.String[]]
        $AttackSurfaceReductionExcludedPaths,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $UntrustedExecutableType,

        # In next Breaking Change set it to 'notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeCommunicationAppsLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $EmailContentExecutionType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $ScriptDownloadedPayloadExecutionType,

        [Parameter()]
        [System.String[]]
        $AdditionalGuardedFolders,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $AdobeReaderLaunchChildProcess,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsExecutableContentCreationOrLaunchType,

        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'enable', 'auditMode', 'warn')]
        [System.String]
        $PreventCredentialStealingType,

        # In next Breaking Change set it to 'notConfigured', 'block', 'auditMode', 'warn', 'disable', don't forget to update the schema as well
        [Parameter()]
        [ValidateSet('notConfigured', 'userDefined', 'block', 'auditMode', 'warn', 'disable')]
        [System.String]
        $OfficeAppsOtherProcessInjectionType,

        [Parameter()]
        [System.String[]]
        $GuardedFoldersAllowedAppPaths,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing configuration of Endpoint Protection Attack Surface Protection rules Policy {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $ValuesToCheck.Remove('Identity') | Out-Null
    $testResult = $true
    #region Assignments
    if ($testResult)
    {
        $source = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $PSBoundParameters.Assignments
        $target = $CurrentValues.Assignments
        $testResult = Compare-M365DSCIntunePolicyAssignment -Source $source -Target $target
        $ValuesToCheck.Remove('Assignments') | Out-Null
    }
    #endregion

    if ($testResult)
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

    $dscContent = ''
    $i = 1

    try
    {
        $policyTemplateID = '0e237410-1367-4844-bd7f-15fb0f08943b'
        [array]$policies = Get-MgBetaDeviceManagementIntent -Filter $Filter -All:$true `
            -ErrorAction Stop | Where-Object -FilterScript { $_.TemplateId -eq $policyTemplateID }

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
                Identity              = $policy.Id
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
            $Results = Get-TargetResource @params

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

            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            $i++

        }
        return $dscContent
    }
    catch
    {
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*' -or `
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

function Get-M365DSCIntuneDeviceConfigurationSettings
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties,

        [Parameter()]
        [System.String]
        $TemplateId
    )

    $templateCategoryId = (Get-MgBetaDeviceManagementTemplateCategory -DeviceManagementTemplateId $TemplateId).Id
    $templateSettings = Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting `
        -DeviceManagementTemplateId $TemplateId `
        -DeviceManagementTemplateSettingCategoryId $templateCategoryId

    $results = @()
    foreach ($setting in $templateSettings)
    {
        $result = @{}
        $settingType = $setting.AdditionalProperties.'@odata.type'
        $settingValue = $null
        $currentValueKey = $Properties.keys | Where-Object -FilterScript { $setting.DefinitionId -like "*$_" }
        if ($null -ne $currentValueKey)
        {
            $settingValue = $Properties.$currentValueKey
        }

        switch ($settingType)
        {
            '#microsoft.graph.deviceManagementStringSettingInstance'
            {
                if ([String]::IsNullOrEmpty($settingValue))
                {
                    $settingValue = $setting.ValueJson
                }
                else
                {
                    $settingValue = ConvertTo-Json -InputObject $settingValue
                }
            }
            '#microsoft.graph.deviceManagementCollectionSettingInstance'
            {
                if ($null -eq $settingValue)
                {
                    $settingValue = ConvertTo-Json -InputObject @()
                }
                else
                {
                    $settingValue = ConvertTo-Json -InputObject ([Array]$settingValue)
                }
            }
            Default
            {
                $settingValue = $setting.ValueJson
            }
        }        $result.Add('@odata.type', $settingType)
        $result.Add('Id', $setting.Id)
        $result.Add('definitionId', $setting.DefinitionId)
        $result.Add('valueJson', ($settingValue ))

        $results += $result
    }
    return $results
}

Export-ModuleMember -Function *-TargetResource
