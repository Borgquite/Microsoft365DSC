function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        #region resource generator code
        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AccountManagerPolicy,

        [Parameter()]
        [ValidateSet('notConfigured', 'guest', 'domain')]
        [System.String[]]
        $AllowedAccounts,

        [Parameter()]
        [System.Boolean]
        $AllowLocalStorage,

        [Parameter()]
        [System.Boolean]
        $DisableAccountManager,

        [Parameter()]
        [System.Boolean]
        $DisableEduPolicies,

        [Parameter()]
        [System.Boolean]
        $DisablePowerPolicies,

        [Parameter()]
        [System.Boolean]
        $DisableSignInOnResume,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $FastFirstSignIn,

        [Parameter()]
        [System.Int32]
        $IdleTimeBeforeSleepInSeconds,

        [Parameter()]
        [System.String]
        $KioskAppDisplayName,

        [Parameter()]
        [System.String]
        $KioskAppUserModelId,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $LocalStorage,

        [Parameter()]
        [System.TimeSpan]
        $MaintenanceStartTime,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetAccountManager,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetEduPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetPowerPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SignInOnResume,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

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

    Write-Verbose -Message "Getting configuration of the Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$Id} and DisplayName {$DisplayName}"

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
            if (-not [string]::IsNullOrEmpty($Id))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$Id'" -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$Id}"

                if (-Not [string]::IsNullOrEmpty($DisplayName))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                        -All `
                        -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue | Where-Object `
                        -FilterScript { `
                            $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.sharedPCConfiguration' `
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Device Configuration Shared Multi Device Policy for Windows10 with DisplayName {$DisplayName}"
                return $nullResult
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }
        $Id = $getValue.Id
        Write-Verbose -Message "An Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$Id} and DisplayName {$DisplayName} was found."

        #region resource generator code
        $complexAccountManagerPolicy = @{}
        if ($null -ne $getValue.AdditionalProperties.accountManagerPolicy.accountDeletionPolicy)
        {
            $complexAccountManagerPolicy.Add('AccountDeletionPolicy', $getValue.AdditionalProperties.accountManagerPolicy.accountDeletionPolicy.toString())
        }
        $complexAccountManagerPolicy.Add('CacheAccountsAboveDiskFreePercentage', $getValue.AdditionalProperties.accountManagerPolicy.cacheAccountsAboveDiskFreePercentage)
        $complexAccountManagerPolicy.Add('InactiveThresholdDays', $getValue.AdditionalProperties.accountManagerPolicy.inactiveThresholdDays)
        $complexAccountManagerPolicy.Add('RemoveAccountsBelowDiskFreePercentage', $getValue.AdditionalProperties.accountManagerPolicy.removeAccountsBelowDiskFreePercentage)
        if ($complexAccountManagerPolicy.values.Where({ $null -ne $_ }).count -eq 0)
        {
            $complexAccountManagerPolicy = $null
        }
        #endregion

        #region resource generator code
        $enumAllowedAccounts = @()
        if ($null -ne $getValue.AdditionalProperties.allowedAccounts)
        {
            $allowedAccounts = $getValue.AdditionalProperties.allowedAccounts.ToString().split(',')
            foreach ($allowedAccount in $allowedAccounts)
            {
                $enumAllowedAccounts += $allowedAccount
            }
        }

        $enumFastFirstSignIn = $null
        if ($null -ne $getValue.AdditionalProperties.fastFirstSignIn)
        {
            $enumFastFirstSignIn = $getValue.AdditionalProperties.fastFirstSignIn.ToString()
        }

        $enumLocalStorage = $null
        if ($null -ne $getValue.AdditionalProperties.localStorage)
        {
            $enumLocalStorage = $getValue.AdditionalProperties.localStorage.ToString()
        }

        $enumSetAccountManager = $null
        if ($null -ne $getValue.AdditionalProperties.setAccountManager)
        {
            $enumSetAccountManager = $getValue.AdditionalProperties.setAccountManager.ToString()
        }

        $enumSetEduPolicies = $null
        if ($null -ne $getValue.AdditionalProperties.setEduPolicies)
        {
            $enumSetEduPolicies = $getValue.AdditionalProperties.setEduPolicies.ToString()
        }

        $enumSetPowerPolicies = $null
        if ($null -ne $getValue.AdditionalProperties.setPowerPolicies)
        {
            $enumSetPowerPolicies = $getValue.AdditionalProperties.setPowerPolicies.ToString()
        }

        $enumSignInOnResume = $null
        if ($null -ne $getValue.AdditionalProperties.signInOnResume)
        {
            $enumSignInOnResume = $getValue.AdditionalProperties.signInOnResume.ToString()
        }
        #endregion

        #region resource generator code
        $timeMaintenanceStartTime = $null
        if ($null -ne $getValue.AdditionalProperties.maintenanceStartTime)
        {
            $timeMaintenanceStartTime = ([TimeSpan]$getValue.AdditionalProperties.maintenanceStartTime).ToString()
        }
        #endregion

        $results = @{
            #region resource generator code
            AccountManagerPolicy         = $complexAccountManagerPolicy
            AllowedAccounts              = $enumAllowedAccounts
            AllowLocalStorage            = $getValue.AdditionalProperties.allowLocalStorage
            DisableAccountManager        = $getValue.AdditionalProperties.disableAccountManager
            DisableEduPolicies           = $getValue.AdditionalProperties.disableEduPolicies
            DisablePowerPolicies         = $getValue.AdditionalProperties.disablePowerPolicies
            DisableSignInOnResume        = $getValue.AdditionalProperties.disableSignInOnResume
            Enabled                      = $getValue.AdditionalProperties.enabled
            FastFirstSignIn              = $enumFastFirstSignIn
            IdleTimeBeforeSleepInSeconds = $getValue.AdditionalProperties.idleTimeBeforeSleepInSeconds
            KioskAppDisplayName          = $getValue.AdditionalProperties.kioskAppDisplayName
            KioskAppUserModelId          = $getValue.AdditionalProperties.kioskAppUserModelId
            LocalStorage                 = $enumLocalStorage
            MaintenanceStartTime         = $timeMaintenanceStartTime
            SetAccountManager            = $enumSetAccountManager
            SetEduPolicies               = $enumSetEduPolicies
            SetPowerPolicies             = $enumSetPowerPolicies
            SignInOnResume               = $enumSignInOnResume
            Description                  = $getValue.Description
            DisplayName                  = $getValue.DisplayName
            Id                           = $getValue.Id
            RoleScopeTagIds              = $getValue.RoleScopeTagIds
            Ensure                       = 'Present'
            Credential                   = $Credential
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            ApplicationSecret            = $ApplicationSecret
            CertificateThumbprint        = $CertificateThumbprint
            Managedidentity              = $ManagedIdentity.IsPresent
            AccessTokens                 = $AccessTokens
            #endregion
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $Id
        $assignmentResult = @()
        if ($assignmentsValues.Count -gt 0)
        {
            $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                -IncludeDeviceFilter:$true `
                -Assignments ($assignmentsValues)
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
        [Microsoft.Management.Infrastructure.CimInstance]
        $AccountManagerPolicy,

        [Parameter()]
        [ValidateSet('notConfigured', 'guest', 'domain')]
        [System.String[]]
        $AllowedAccounts,

        [Parameter()]
        [System.Boolean]
        $AllowLocalStorage,

        [Parameter()]
        [System.Boolean]
        $DisableAccountManager,

        [Parameter()]
        [System.Boolean]
        $DisableEduPolicies,

        [Parameter()]
        [System.Boolean]
        $DisablePowerPolicies,

        [Parameter()]
        [System.Boolean]
        $DisableSignInOnResume,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $FastFirstSignIn,

        [Parameter()]
        [System.Int32]
        $IdleTimeBeforeSleepInSeconds,

        [Parameter()]
        [System.String]
        $KioskAppDisplayName,

        [Parameter()]
        [System.String]
        $KioskAppUserModelId,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $LocalStorage,

        [Parameter()]
        [System.TimeSpan]
        $MaintenanceStartTime,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetAccountManager,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetEduPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetPowerPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SignInOnResume,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

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

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Device Configuration Shared Multi Device Policy for Windows10 with DisplayName {$DisplayName}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $CreateParameters = ([Hashtable]$BoundParameters).clone()
        $CreateParameters = Rename-M365DSCCimInstanceParameter -Properties $CreateParameters
        $CreateParameters.Remove('Id') | Out-Null

        $keys = (([Hashtable]$CreateParameters).clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $CreateParameters.$key -and $CreateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $CreateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters.$key
            }
        }

        if ($null -ne $AllowedAccounts)
        {
            $CreateParameters.AllowedAccounts = $AllowedAccounts -join ','
        }

        #region resource generator code
        $CreateParameters.Add('@odata.type', '#microsoft.graph.sharedPCConfiguration')
        $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $CreateParameters
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments

        if ($policy.id)
        {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$($currentInstance.Id)}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $UpdateParameters = ([Hashtable]$BoundParameters).clone()
        $UpdateParameters = Rename-M365DSCCimInstanceParameter -Properties $UpdateParameters

        $UpdateParameters.Remove('Id') | Out-Null

        $keys = (([Hashtable]$UpdateParameters).clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $UpdateParameters.$key -and $UpdateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $UpdateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters.$key
            }
        }

        if ($null -ne $AllowedAccounts)
        {
            $UpdateParameters.AllowedAccounts = $AllowedAccounts -join ','
        }
        #region resource generator code
        $UpdateParameters.Add('@odata.type', '#microsoft.graph.sharedPCConfiguration')
        Update-MgBetaDeviceManagementDeviceConfiguration  `
            -DeviceConfigurationId $currentInstance.Id `
            -BodyParameter $UpdateParameters
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment `
            -DeviceConfigurationPolicyId $currentInstance.id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/deviceConfigurations'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing the Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$($currentInstance.Id)}"
        #region resource generator code
        Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
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
        [Microsoft.Management.Infrastructure.CimInstance]
        $AccountManagerPolicy,

        [Parameter()]
        [ValidateSet('notConfigured', 'guest', 'domain')]
        [System.String[]]
        $AllowedAccounts,

        [Parameter()]
        [System.Boolean]
        $AllowLocalStorage,

        [Parameter()]
        [System.Boolean]
        $DisableAccountManager,

        [Parameter()]
        [System.Boolean]
        $DisableEduPolicies,

        [Parameter()]
        [System.Boolean]
        $DisablePowerPolicies,

        [Parameter()]
        [System.Boolean]
        $DisableSignInOnResume,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $FastFirstSignIn,

        [Parameter()]
        [System.Int32]
        $IdleTimeBeforeSleepInSeconds,

        [Parameter()]
        [System.String]
        $KioskAppDisplayName,

        [Parameter()]
        [System.String]
        $KioskAppUserModelId,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $LocalStorage,

        [Parameter()]
        [System.TimeSpan]
        $MaintenanceStartTime,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetAccountManager,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetEduPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SetPowerPolicies,

        [Parameter()]
        [ValidateSet('notConfigured', 'enabled', 'disabled')]
        [System.String]
        $SignInOnResume,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

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

    Write-Verbose -Message "Testing configuration of the Intune Device Configuration Shared Multi Device Policy for Windows10 with Id {$Id} and DisplayName {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($source.getType().Name -like '*CimInstance*')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-Not $testResult)
            {
                $testResult = $false
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck.remove('Id') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

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
        [array]$getValue = Get-MgBetaDeviceManagementDeviceConfiguration -Filter $Filter -All `
            -ErrorAction Stop | Where-Object `
            -FilterScript { `
                $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.sharedPCConfiguration' `
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = $config.Id
            if (-not [String]::IsNullOrEmpty($config.displayName))
            {
                $displayedKey = $config.displayName
            }
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
            $params = @{
                Id                    = $config.Id
                DisplayName           = $config.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $config
            $Results = Get-TargetResource @Params
            if ($null -ne $Results.AccountManagerPolicy)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.AccountManagerPolicy `
                    -CIMInstanceName 'MicrosoftGraphsharedPCAccountManagerPolicy'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.AccountManagerPolicy = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AccountManagerPolicy') | Out-Null
                }
            }
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
                -NoEscape @('AccountManagerPolicy', 'Assignments')

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

Export-ModuleMember -Function *-TargetResource
