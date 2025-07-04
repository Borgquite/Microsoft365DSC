function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Id,

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
        [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
        [System.String]
        $authenticationMethod,

        [Parameter()]
        [System.String]
        $connectionName,

        [Parameter()]
        [System.String]
        $role,

        [Parameter()]
        [System.String]
        $realm,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $servers,

        [Parameter()]
        [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'citrix', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect')]
        [System.String]
        $connectionType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $proxyServer,

        [Parameter()]
        [System.string[]]
        $targetedPackageIds,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $targetedMobileApps,

        [Parameter()]
        [System.Boolean]
        $alwaysOn,

        [Parameter()]
        [System.Boolean]
        $alwaysOnLockdown,

        [Parameter()]
        [System.string]
        $microsoftTunnelSiteId,

        [Parameter()]
        [System.string[]]
        $proxyExclusionList,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customData,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customKeyValueData,

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

    Write-Verbose -Message "Getting configuration of the Intune VPN Policy for Android Device Owner with Id {$Id} and DisplayName {$DisplayName}"

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
            if (-not [string]::IsNullOrWhiteSpace($Id))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$Id'" -ErrorAction SilentlyContinue
            }

            #region resource generator code
            if ($null -eq $getValue)
            {
                $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($Displayname -replace "'", "''")'" -ErrorAction SilentlyContinue | Where-Object `
                -FilterScript { `
                    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidDeviceOwnerVpnConfiguration' `
                }
            }
            #endregion

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Intune VPN Policy for Android Device Owner with Id {$Id} was found"
                return $nullResult
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }

        $Id = $getValue.Id

        Write-Verbose -Message "An Intune VPN Policy for Android Device Owner with id {$Id} and DisplayName {$DisplayName} was found"

        $complexServers = @()
        foreach ($currentservers in $getValue.AdditionalProperties.servers)
        {
            $myservers = @{}
            $myservers.Add('address', $currentservers.address)
            $myservers.Add('description', $currentservers.description)
            $myservers.Add('isDefaultServer', $currentservers.isDefaultServer)
            if ($myservers.values.Where({$null -ne $_}).count -gt 0)
            {
                $complexServers += $myservers
            }
        }

        $complexProxyServers = @()
        foreach ($currentservers in $getValue.AdditionalProperties.proxyServer)
        {
            $myservers = @{}
            $myservers.Add('automaticConfigurationScriptUrl', $currentservers.automaticConfigurationScriptUrl)
            $myservers.Add('address', $currentservers.address)
            $myservers.Add('port', $currentservers.port)
            if ($myservers.values.Where({$null -ne $_}).count -gt 0)
            {
                $complexProxyServers += $myservers
            }
        }

        $complexCustomData = @()
        foreach ($value in $getValue.AdditionalProperties.customData)
        {
            $myCustomdata = @{}
            $myCustomdata.Add('key', $value.key)
            $myCustomdata.Add('value', $value.value)
            if ($myCustomdata.values.Where({$null -ne $_}).count -gt 0)
            {
                $complexCustomData += $myCustomdata
            }
        }

        $complexCustomKeyValueData = @()
        foreach ($value in $getValue.AdditionalProperties.customKeyValueData)
        {
            $myCVdata = @{}
            $myCVdata.Add('name', $value.name)
            $myCVdata.Add('value', $value.value)
            if ($myCVdata.values.Where({$null -ne $_}).count -gt 0)
            {
                $complexCustomKeyValueData += $myCVdata
            }
        }

        $complexTargetedMobileApps = @()
        foreach ($value in $getValue.AdditionalProperties.targetedMobileApps)
        {
            $myTMAdata = @{}
            $myTMAdata.Add('name', $value.name)
            $myTMAdata.Add('publisher', $value.publisher)
            $myTMAdata.Add('appStoreUrl', $value.appStoreUrl)
            $myTMAdata.Add('appId', $value.appId)
            if ($myTMAdata.values.Where({$null -ne $_}).count -gt 0)
            {
                $complexTargetedMobileApps += $myTMAdata
            }
        }

        $results = @{
            #region resource generator code
            Id                             = $getValue.Id
            Description                    = $getValue.Description
            DisplayName                    = $getValue.DisplayName
            RoleScopeTagIds                = $getValue.RoleScopeTagIds
            authenticationMethod           = $getValue.AdditionalProperties.authenticationMethod
            connectionName                 = $getValue.AdditionalProperties.connectionName
            role                           = $getValue.AdditionalProperties.role
            realm                          = $getValue.AdditionalProperties.realm
            servers                        = $complexServers
            connectionType                 = $getValue.AdditionalProperties.connectionType
            proxyServer                    = $complexProxyServers
            targetedPackageIds             = $getValue.AdditionalProperties.targetedPackageIds
            targetedMobileApps             = $complexTargetedMobileApps
            alwaysOn                       = $getValue.AdditionalProperties.alwaysOn
            alwaysOnLockdown               = $getValue.AdditionalProperties.alwaysOnLockdown
            microsoftTunnelSiteId          = $getValue.AdditionalProperties.microsoftTunnelSiteId
            proxyExclusionList             = $getValue.AdditionalProperties.proxyExclusionList
            customData                     = $complexCustomData
            customKeyValueData             = $complexCustomKeyValueData
            Ensure                         = 'Present'
            Credential                     = $Credential
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            ApplicationSecret              = $ApplicationSecret
            CertificateThumbprint          = $CertificateThumbprint
            Managedidentity                = $ManagedIdentity.IsPresent
            AccessTokens                   = $AccessTokens
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $Results.Id
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
        [System.String]
        $Id,

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
        [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
        [System.String]
        $authenticationMethod,

        [Parameter()]
        [System.String]
        $connectionName,

        [Parameter()]
        [System.String]
        $role,

        [Parameter()]
        [System.String]
        $realm,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $servers,

        [Parameter()]
        [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'citrix', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect')]
        [System.String]
        $connectionType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $proxyServer,

        [Parameter()]
        [System.string[]]
        $targetedPackageIds,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $targetedMobileApps,

        [Parameter()]
        [System.Boolean]
        $alwaysOn,

        [Parameter()]
        [System.Boolean]
        $alwaysOnLockdown,

        [Parameter()]
        [System.string]
        $microsoftTunnelSiteId,

        [Parameter()]
        [System.string[]]
        $proxyExclusionList,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customData,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customKeyValueData,

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

    try
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
            -InboundParameters $PSBoundParameters
    }
    catch
    {
        Write-Verbose -Message $_
    }

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

    #proxy and server values need converting before new- / update- cmdlets will accept parameters
    #creating hashtables now for use later in both present/present and present/absent blocks
    $allTargetValues = Convert-M365DscHashtableToString -Hashtable $BoundParameters

    if ($allTargetValues -match '\bproxyServer=\(\{([^\)]+)\}\)')
    {
        $proxyBlock = $matches[1]
    }

    $proxyHashtable = @{}
    $proxyBlock -split ";" | ForEach-Object {
        if ($_ -match '^(.*?)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $proxyHashtable[$key] = $value
        }
    }

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating {$DisplayName}"
        $BoundParameters.Remove('Assignments') | Out-Null
        $CreateParameters = ([Hashtable]$BoundParameters).clone()
        $CreateParameters = Rename-M365DSCCimInstanceParameter -Properties $CreateParameters
        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($CreateParameters)

        foreach ($key in $AdditionalProperties.keys)
        {
            if ($key -ne '@odata.type')
            {
                $keyName = $key.substring(0, 1).ToUpper() + $key.substring(1, $key.length - 1)
                $CreateParameters.remove($keyName)
            }
        }

        $CreateParameters.Remove('Id') | Out-Null

        foreach ($key in ($CreateParameters.clone()).Keys)
        {
            if ($CreateParameters[$key].getType().Fullname -like '*CimInstance*')
            {
                $CreateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters[$key]
            }
        }

        if ($AdditionalProperties.proxyServer)
        {
            $AdditionalProperties.Remove('proxyServer') #this is not in a format Update-MgBetaDeviceManagementDeviceConfiguration will accept
            $AdditionalProperties.add('proxyServer',$proxyHashtable) #replaced with the hashtable we created earlier
        }

        $CreateParameters.add('AdditionalProperties', $AdditionalProperties)

        #region resource generator code
        $policy = New-MgBetaDeviceManagementDeviceConfiguration @CreateParameters
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
        Write-Verbose -Message "Updating {$DisplayName}"

        $BoundParameters.Remove('Assignments') | Out-Null
        $UpdateParameters = ([Hashtable]$BoundParameters).clone()
        $UpdateParameters = Rename-M365DSCCimInstanceParameter -Properties $UpdateParameters
        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($UpdateParameters)

        foreach ($key in $AdditionalProperties.keys)
        {
            if ($key -ne '@odata.type')
            {
                $keyName = $key.substring(0, 1).ToUpper() + $key.substring(1, $key.length - 1)
                $UpdateParameters.remove($keyName)
            }
        }

        $UpdateParameters.Remove('Id') | Out-Null

        foreach ($key in ($UpdateParameters.clone()).Keys)
        {
            if ($UpdateParameters[$key].getType().Fullname -like '*CimInstance*')
            {
                $UpdateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters[$key]
            }
        }

        if ($AdditionalProperties.proxyServer)
        {
            $AdditionalProperties.Remove('proxyServer') #this is not in a format Update-MgBetaDeviceManagementDeviceConfiguration will accept
            $AdditionalProperties.add('proxyServer',$proxyHashtable) #replaced with the hashtable we created earlier
        }

        if ($AdditionalProperties)
        {
            #add the additional properties to the updateparameters
            $UpdateParameters.add('AdditionalProperties', $AdditionalProperties)
        }

        #region resource generator code
        Update-MgBetaDeviceManagementDeviceConfiguration @UpdateParameters `
            -DeviceConfigurationId $currentInstance.Id
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/deviceConfigurations'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing {$DisplayName}"
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
        [System.String]
        $Id,

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
        [ValidateSet('certificate', 'usernameAndPassword', 'sharedSecret', 'derivedCredential', 'azureAD')]
        [System.String]
        $authenticationMethod,

        [Parameter()]
        [System.String]
        $connectionName,

        [Parameter()]
        [System.String]
        $role,

        [Parameter()]
        [System.String]
        $realm,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $servers,

        [Parameter()]
        [ValidateSet('ciscoAnyConnect', 'pulseSecure', 'f5EdgeClient', 'dellSonicWallMobileConnect', 'checkPointCapsuleVpn', 'citrix', 'microsoftTunnel', 'netMotionMobility', 'microsoftProtect')]
        [System.String]
        $connectionType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $proxyServer,

        [Parameter()]
        [System.string[]]
        $targetedPackageIds,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $targetedMobileApps,

        [Parameter()]
        [System.Boolean]
        $alwaysOn,

        [Parameter()]
        [System.Boolean]
        $alwaysOnLockdown,

        [Parameter()]
        [System.string]
        $microsoftTunnelSiteId,

        [Parameter()]
        [System.string[]]
        $proxyExclusionList,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customData,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $customKeyValueData,

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

    Write-Verbose -Message "Testing configuration of {$id}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($source.GetType().Name -like '*CimInstance*')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-not $testResult) { break }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck.Remove('Id') | Out-Null
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    #Convert any DateTime to String
    foreach ($key in $ValuesToCheck.Keys)
    {
        if (($null -ne $CurrentValues[$key]) `
                -and ($CurrentValues[$key].getType().Name -eq 'DateTime'))
        {
            $CurrentValues[$key] = $CurrentValues[$key].toString()
        }
    }

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
                $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.androidDeviceOwnerVpnConfiguration'  `
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

            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -DeferWrite
            $params = @{
                Id                    = $config.id
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

            if ($null -ne $Results.servers)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.servers `
                    -CIMInstanceName 'MicrosoftGraphvpnServer' #MSFT_MicrosoftGraphVpnServer
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.servers = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('servers') | Out-Null
                }
            }

            if ($null -ne $Results.proxyServer)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.proxyServer `
                    -CIMInstanceName 'MSFT_MicrosoftvpnProxyServer'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.proxyServer = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('proxyServer') | Out-Null
                }
            }

            if ($null -ne $Results.customData)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.customData `
                    -CIMInstanceName 'MSFT_CustomData'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.customData = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('customData') | Out-Null
                }
            }

            if ($null -ne $Results.customKeyValueData)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.customKeyValueData `
                    -CIMInstanceName 'MSFT_customKeyValueData'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.customKeyValueData = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('customKeyValueData') | Out-Null
                }
            }

            if ($null -ne $Results.targetedMobileApps)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.targetedMobileApps `
                    -CIMInstanceName 'MSFT_targetedMobileApps'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.targetedMobileApps = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('targetedMobileApps') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('servers', 'proxyServer', 'customData', 'customKeyValueData', 'targetedMobileApps', 'Assignments')

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
        $_.Exception -like "*Request not applicable to target tenant*")
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

function Get-M365DSCAdditionalProperties
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties
    )

    $additionalProperties = @(
        'authenticationMethod'
        'connectionName'
        'role'
        'realm'
        'servers'
        'connectionType'
        'proxyServer'
        'targetedPackageIds'
        'targetedMobileApps'
        'alwaysOn'
        'alwaysOnLockdown'
        'microsoftTunnelSiteId'
        'proxyExclusionList'
        'customData'
        'customKeyValueData'
    )

    $results = @{'@odata.type' = '#microsoft.graph.androidDeviceOwnerVpnConfiguration' }
    $cloneProperties = $Properties.clone()
    foreach ($property in $cloneProperties.Keys)
    {
        if ($property -in ($additionalProperties) )
        {
            $propertyName = $property[0].ToString().ToLower() + $property.Substring(1, $property.Length - 1)
            if ($properties.$property -and $properties.$property.getType().FullName -like '*CIMInstance*')
            {
                if ($properties.$property.getType().FullName -like '*[[\]]')
                {
                    $array = @()
                    foreach ($item in $properties.$property)
                    {
                        $array += Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $item
                    }
                    $propertyValue = $array
                }
                else
                {
                    $propertyValue = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $properties.$property
                }

            }
            else
            {
                $propertyValue = $properties.$property
            }

            $results.Add($propertyName, $propertyValue)
        }
    }
    if ($results.Count -eq 1)
    {
        return $null
    }
    return $results
}

Export-ModuleMember -Function *-TargetResource
