function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [Boolean]
        $AzureADJoinIsAdminConfigurable,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureADAllowedToJoin,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinUsers,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinGroups,

        [Parameter()]
        [System.Boolean]
        $MultiFactorAuthConfiguration,

        [Parameter()]
        [System.Boolean]
        $LocalAdminsEnableGlobalAdmins,

        [Parameter()]
        [System.Boolean]
        $LocalAdminPasswordIsEnabled,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureAdJoinLocalAdminsRegisteringMode,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringGroups,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringUsers,

        [Parameter()]
        [System.UInt32]
        $UserDeviceQuota,

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

    try
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

        $getValue = Get-MgBetaPolicyDeviceRegistrationPolicy -ErrorAction Stop

        $AzureADAllowedToJoin = 'None'
        $AzureADAllowedToJoinUsers = @()
        $AzureADAllowedToJoinGroups = @()
        if ($getValue.AzureADJoin.AllowedToJoin.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.allDeviceRegistrationMembership')
        {
            $AzureADAllowedToJoin = 'All'
        }
        elseif ($getValue.AzureADJoin.AllowedToJoin.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
        {
            $AzureADAllowedToJoin = 'Selected'

            foreach ($userId in $getValue.AzureAdJoin.AllowedToJoin.AdditionalProperties.users)
            {
                try
                {
                    $userInfo = Get-MgUser -UserId $userId -ErrorAction Stop
                    $AzureADAllowedToJoinUsers += $userInfo.UserPrincipalName
                }
                catch
                {
                    $message = "Could not find a user with id $($userId) specified in AllowedToJoin. Skipping user!"
                    New-M365DSCLogEntry -Message $message `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                    continue
                }
            }

            foreach ($groupId in $getValue.AzureAdJoin.AllowedToJoin.AdditionalProperties.groups)
            {
                try
                {
                    $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction Stop
                    $AzureADAllowedToJoinGroups += $groupInfo.DisplayName
                }
                catch
                {
                    $message = "Could not find a group with id $($groupId) specified in AllowedToJoin. Skipping group!"
                    New-M365DSCLogEntry -Message $message `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                    continue
                }
            }
        }

        $AzureAdJoinLocalAdminsRegisteringUsers = @()
        $AzureAdJoinLocalAdminsRegisteringGroups = @()
        $AzureAdJoinLocalAdminsRegisteringMode = 'All'

        if ($getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.noDeviceRegistrationMembership')
        {
            $AzureAdJoinLocalAdminsRegisteringMode = 'None'
        }
        elseif ($getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
        {
            $AzureAdJoinLocalAdminsRegisteringMode = 'Selected'
            foreach ($userId in $getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.AdditionalProperties.users)
            {
                try
                {
                    $userInfo = Get-MgUser -UserId $userId -ErrorAction Stop
                    $AzureAdJoinLocalAdminsRegisteringUsers += $userInfo.UserPrincipalName
                }
                catch
                {
                    $message = "Could not find a user with id $($userId) specified in AllowedToJoin. Skipping user!"
                    New-M365DSCLogEntry -Message $message `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                    continue
                }
            }

            foreach ($groupId in $getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.AdditionalProperties.groups)
            {
                try
                {
                    $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction Stop
                    $AzureAdJoinLocalAdminsRegisteringGroups += $groupInfo.DisplayName
                }
                catch
                {
                    $message = "Could not find a group with id $($groupId) specified in AllowedToJoin. Skipping group!"
                    New-M365DSCLogEntry -Message $message `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                    continue
                }
            }
        }

        $MultiFactorAuthConfiguration = $false
        if ($getValue.MultiFactorAuthConfiguration -eq 'required')
        {
            $MultiFactorAuthConfiguration = $true
        }
        $LocalAdminsEnableGlobalAdmins = $true
        if (-not $getValue.AzureAdJoin.LocalAdmins.EnableGlobalAdmins)
        {
            $LocalAdminsEnableGlobalAdmins = $false
        }
        $results = @{
            IsSingleInstance                        = 'Yes'
            AzureADJoinIsAdminConfigurable          = [Boolean]$getValue.AzureAdJoin.IsAdminConfigurable
            AzureADAllowedToJoin                    = $AzureADAllowedToJoin
            AzureADAllowedToJoinGroups              = $AzureADAllowedToJoinGroups
            AzureADAllowedToJoinUsers               = $AzureADAllowedToJoinUsers
            UserDeviceQuota                         = $getValue.UserDeviceQuota
            MultiFactorAuthConfiguration            = $MultiFactorAuthConfiguration
            LocalAdminsEnableGlobalAdmins           = $LocalAdminsEnableGlobalAdmins
            LocalAdminPasswordIsEnabled             = [Boolean]$getValue.LocalAdminPassword.IsEnabled
            AzureAdJoinLocalAdminsRegisteringMode   = $AzureAdJoinLocalAdminsRegisteringMode
            AzureAdJoinLocalAdminsRegisteringGroups = $AzureAdJoinLocalAdminsRegisteringGroups
            AzureAdJoinLocalAdminsRegisteringUsers  = $AzureAdJoinLocalAdminsRegisteringUsers
            Credential                              = $Credential
            ApplicationId                           = $ApplicationId
            TenantId                                = $TenantId
            ApplicationSecret                       = $ApplicationSecret
            CertificateThumbprint                   = $CertificateThumbprint
            Managedidentity                         = $ManagedIdentity.IsPresent
            AccessTokens                            = $AccessTokens
        }

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
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [Boolean]
        $AzureADJoinIsAdminConfigurable,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureADAllowedToJoin,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinUsers,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinGroups,

        [Parameter()]
        [System.Boolean]
        $MultiFactorAuthConfiguration,

        [Parameter()]
        [System.Boolean]
        $LocalAdminsEnableGlobalAdmins,

        [Parameter()]
        [System.Boolean]
        $LocalAdminPasswordIsEnabled,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureAdJoinLocalAdminsRegisteringMode,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringGroups,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringUsers,

        [Parameter()]
        [System.UInt32]
        $UserDeviceQuota,

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

    $MultiFactorAuthConfigurationValue = 'notRequired'
    if ($MultiFactorAuthConfiguration)
    {
        $MultiFactorAuthConfigurationValue = 'required'
    }

    $azureADRegistrationAllowedToRegister = '#microsoft.graph.noDeviceRegistrationMembership'
    if ($AzureADAllowedToJoin -eq 'All')
    {
        $azureADRegistrationAllowedToRegister = '#microsoft.graph.allDeviceRegistrationMembership'
    }
    elseif ($AzureADAllowedToJoin -eq 'Selected')
    {
        $azureADRegistrationAllowedToRegister = '#microsoft.graph.enumeratedDeviceRegistrationMembership'

        $azureADRegistrationAllowedUsers = @()
        foreach ($user in $AzureADAllowedToJoinUsers)
        {
            $userInfo = Get-MgUser -UserId $user
            $azureADRegistrationAllowedUsers += $userInfo.Id
        }

        $azureADRegistrationAllowedGroups = @()
        foreach ($group in $AzureADAllowedToJoinGroups)
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($group -replace "'", "''")'"
            $azureADRegistrationAllowedGroups += $groupInfo.Id
        }
    }

    $localAdminAllowedMode = '#microsoft.graph.noDeviceRegistrationMembership'
    if ($AzureAdJoinLocalAdminsRegisteringMode -eq 'All')
    {
        $localAdminAllowedMode = '#microsoft.graph.allDeviceRegistrationMembership'
    }
    elseif ($AzureAdJoinLocalAdminsRegisteringMode -eq 'Selected')
    {
        $localAdminAllowedMode = '#microsoft.graph.enumeratedDeviceRegistrationMembership'

        $localAdminAllowedUsers = @()
        foreach ($user in $AzureAdJoinLocalAdminsRegisteringUsers)
        {
            $userInfo = Get-MgUser -UserId $user
            $localAdminAllowedUsers += $userInfo.Id
        }

        $localAdminAllowedGroups = @()
        foreach ($group in $AzureAdJoinLocalAdminsRegisteringGroups)
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($group -replace "'", "''")'"
            $localAdminAllowedGroups += $groupInfo.Id
        }
    }

    $updateParameters = @{
        userDeviceQuota              = $UserDeviceQuota
        multiFactorAuthConfiguration = $MultiFactorAuthConfigurationValue
        azureADJoin                  = @{
            isAdminConfigurable = $AzureADJoinIsAdminConfigurable
            allowedToJoin       = @{
                '@odata.type' = $azureADRegistrationAllowedToRegister
                users         = $azureADRegistrationAllowedUsers
                groups        = $azureADRegistrationAllowedGroups
            }
            localAdmins         = @{
                enableGlobalAdmins = $LocalAdminsEnableGlobalAdmins
                registeringUsers   = @{
                    '@odata.type' = $localAdminAllowedMode
                    users         = $localAdminAllowedUsers
                    groups        = $localAdminAllowedGroups
                }
            }
        }
        localAdminPassword           = @{
            isEnabled = $LocalAdminPasswordIsEnabled
        }
        azureADRegistration          = @{
            isAdminConfigurable = $false
            allowedToRegister   = @{
                '@odata.type' = '#microsoft.graph.allDeviceRegistrationMembership'
            }
        }
    }
    $uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'beta/policies/deviceRegistrationPolicy'
    Write-Verbose -Message "Updating Device Registration Policy with payload:`r`n$(ConvertTo-Json $updateParameters -Depth 10)"
    Invoke-MgGraphRequest -Method PUT -Uri $uri -Body $updateParameters
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [Boolean]
        $AzureADJoinIsAdminConfigurable,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureADAllowedToJoin,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinUsers,

        [Parameter()]
        [System.String[]]
        $AzureADAllowedToJoinGroups,

        [Parameter()]
        [System.Boolean]
        $MultiFactorAuthConfiguration,

        [Parameter()]
        [System.Boolean]
        $LocalAdminsEnableGlobalAdmins,

        [Parameter()]
        [System.Boolean]
        $LocalAdminPasswordIsEnabled,

        [Parameter()]
        [ValidateSet('All', 'Selected', 'None')]
        [System.String]
        $AzureAdJoinLocalAdminsRegisteringMode,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringGroups,

        [Parameter()]
        [System.String[]]
        $AzureAdJoinLocalAdminsRegisteringUsers,

        [Parameter()]
        [System.UInt32]
        $UserDeviceQuota,

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

    Write-Verbose -Message 'Testing configuration of the Device Registration Policy'

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"
    $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

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
        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
        {
            $Global:M365DSCExportResourceInstancesCount++
        }
        $params = @{
            IsSingleInstance      = 'Yes'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }

        $Results = Get-TargetResource @Params

        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
            -ConnectionMode $ConnectionMode `
            -ModulePath $PSScriptRoot `
            -Results $Results `
            -Credential $Credential

        $dscContent = $currentDSCBlock
        Save-M365DSCPartialExport -Content $currentDSCBlock `
            -FileName $Global:PartialExportFileName
        $i++
        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        return $dscContent
    }
    catch
    {
        if ($_.ErrorDetails.Message -like '*Insufficient privileges*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Insufficient permissions or license to export Attribute Sets."
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
