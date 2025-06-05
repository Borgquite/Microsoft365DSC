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
        [System.Boolean]
        $ConnectAutomatically,

        [Parameter()]
        [System.Boolean]
        $ConnectWhenNetworkNameIsHidden,

        [Parameter()]
        [System.Boolean]
        $DisableMacAddressRandomization,

        [Parameter()]
        [System.Boolean]
        $ForcePreSharedKeyUpdate,

        [Parameter()]
        [System.String]
        $NetworkName,

        [Parameter()]
        [System.String]
        $PreSharedKey,

        [Parameter()]
        [System.String]
        $ProxyAutomaticConfigurationUrl,

        [Parameter()]
        [System.String]
        $ProxyManualAddress,

        [Parameter()]
        [System.Int32]
        $ProxyManualPort,

        [Parameter()]
        [ValidateSet('none', 'manual', 'automatic')]
        [System.String]
        $ProxySettings,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Ssid,

        [Parameter()]
        [ValidateSet('open', 'wpaPersonal', 'wpaEnterprise', 'wep', 'wpa2Personal', 'wpa2Enterprise')]
        [System.String]
        $WiFiSecurityType,

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

    Write-Verbose -Message "Getting configuration of the Intune Wifi Configuration Policy for iOS with id {$Id} and DisplayName {$DisplayName}"

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
            if (-not [string]::IsNullOrEmpty($Id))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $Id -ErrorAction SilentlyContinue
            }

            #region resource generator code
            if ($null -eq $getValue)
            {
                $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue | Where-Object `
                    -FilterScript { `
                        $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosWiFiConfiguration' `
                }
            }
            #endregion

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Intune Wifi Configuration Policy for iOS with id {$Id} was found"
                return $nullResult
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }
        $Id = $getValue.Id

        Write-Verbose -Message "Found an Intune Wifi Configuration Policy for iOS with id {$Id}"
        $results = @{
            #region resource generator code
            Id                             = $getValue.Id
            Description                    = $getValue.Description
            DisplayName                    = $getValue.DisplayName
            ConnectAutomatically           = $getValue.AdditionalProperties.connectAutomatically
            ConnectWhenNetworkNameIsHidden = $getValue.AdditionalProperties.connectWhenNetworkNameIsHidden
            DisableMacAddressRandomization = $getValue.AdditionalProperties.disableMacAddressRandomization
            NetworkName                    = $getValue.AdditionalProperties.networkName
            PreSharedKey                   = $getValue.AdditionalProperties.preSharedKey
            ProxyAutomaticConfigurationUrl = $getValue.AdditionalProperties.proxyAutomaticConfigurationUrl
            ProxyManualAddress             = $getValue.AdditionalProperties.proxyManualAddress
            ProxyManualPort                = $getValue.AdditionalProperties.proxyManualPort
            ProxySettings                  = $getValue.AdditionalProperties.proxySettings
            RoleScopeTagIds                = $getValue.RoleScopeTagIds
            Ssid                           = $getValue.AdditionalProperties.ssid
            WiFiSecurityType               = $getValue.AdditionalProperties.wiFiSecurityType
            Ensure                         = 'Present'
            Credential                     = $Credential
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            ApplicationSecret              = $ApplicationSecret
            CertificateThumbprint          = $CertificateThumbprint
            ManagedIdentity                = $ManagedIdentity.IsPresent
            AccessTokens                   = $AccessTokens
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
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Boolean]
        $ConnectAutomatically,

        [Parameter()]
        [System.Boolean]
        $ConnectWhenNetworkNameIsHidden,

        [Parameter()]
        [System.Boolean]
        $DisableMacAddressRandomization,

        [Parameter()]
        [System.Boolean]
        $ForcePreSharedKeyUpdate,

        [Parameter()]
        [System.String]
        $NetworkName,

        [Parameter()]
        [System.String]
        $PreSharedKey,

        [Parameter()]
        [System.String]
        $ProxyAutomaticConfigurationUrl,

        [Parameter()]
        [System.String]
        $ProxyManualAddress,

        [Parameter()]
        [System.Int32]
        $ProxyManualPort,

        [Parameter()]
        [ValidateSet('none', 'manual', 'automatic')]
        [System.String]
        $ProxySettings,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Ssid,

        [Parameter()]
        [ValidateSet('open', 'wpaPersonal', 'wpaEnterprise', 'wep', 'wpa2Personal', 'wpa2Enterprise')]
        [System.String]
        $WiFiSecurityType,

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

    if ($ProxySettings -ne 'automatic' -and $ProxyAutomaticConfigurationUrl -ne '') {
        throw 'ProxyAutomaticConfigurationUrl must be empty if ProxySettings is not "automatic"'
    }

    if ($WiFiSecurityType -eq 'wpaPersonal' -and [string]::IsNullOrEmpty($PreSharedKey)) {
        throw 'PreSharedKey is required but was not set.'
    }

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

    $currentInstance = Get-TargetResource @PSBoundParameters
    $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Wifi Configuration Policy for iOS with DisplayName {$DisplayName}"
        $CreateParameters = ([Hashtable]$BoundParameters).Clone()
        $CreateParameters.Remove('Id') | Out-Null
        $CreateParameters.Remove('Assignments') | Out-Null
        $CreateParameters.Remove('ForcePreSharedKeyUpdate') | Out-Null

        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($CreateParameters)
        foreach ($key in $AdditionalProperties.keys)
        {
            if ($key -ne '@odata.type')
            {
                $keyName = $key.Substring(0, 1).ToUpper() + $key.Substring(1, $key.Length - 1)
                $CreateParameters.Remove($keyName) | Out-Null
            }
        }

        foreach ($key in ($CreateParameters.Clone()).Keys)
        {
            if ($CreateParameters[$key].GetType().Fullname -like '*CimInstance*')
            {
                $CreateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters[$key]
            }
        }

        if ($AdditionalProperties)
        {
            if ($AdditionalProperties['proxyAutomaticConfigurationUrl'] -eq '') {
                $AdditionalProperties['proxyAutomaticConfigurationUrl'] = $null
            }
            $CreateParameters.Add('AdditionalProperties', $AdditionalProperties)
        }

        #region resource generator code
        $policy = New-MgBetaDeviceManagementDeviceConfiguration @CreateParameters
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments

        if ($policy.Id)
        {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Intune Wifi Configuration Policy for iOS with Id {$Id} and DisplayName {$DisplayName}"

        $UpdateParameters = ([Hashtable]$BoundParameters).Clone()
        $UpdateParameters.Remove('Id') | Out-Null
        $UpdateParameters.Remove('Assignments') | Out-Null
        $UpdateParameters.Remove('ForcePreSharedKeyUpdate') | Out-Null

        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($UpdateParameters)
        foreach ($key in $AdditionalProperties.keys)
        {
            if ($key -ne '@odata.type')
            {
                $keyName = $key.Substring(0, 1).ToUpper() + $key.Substring(1, $key.Length - 1)
                $UpdateParameters.Remove($keyName)
            }
        }

        foreach ($key in ($UpdateParameters.Clone()).Keys)
        {
            if ($UpdateParameters[$key].GetType().Fullname -like '*CimInstance*')
            {
                $UpdateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters[$key]
            }
        }

        if ($AdditionalProperties)
        {
            if ($AdditionalProperties['proxyAutomaticConfigurationUrl'] -eq '') {
                $AdditionalProperties['proxyAutomaticConfigurationUrl'] = $null
            }
            $UpdateParameters.Add('AdditionalProperties', $AdditionalProperties)
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
        Write-Verbose -Message "Removing the Intune Wifi Configuration Policy for iOS with Id {$($currentInstance.Id)} and DisplayName {$DisplayName}"
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
        [System.Boolean]
        $ConnectAutomatically,

        [Parameter()]
        [System.Boolean]
        $ConnectWhenNetworkNameIsHidden,

        [Parameter()]
        [System.Boolean]
        $DisableMacAddressRandomization,

        [Parameter()]
        [System.Boolean]
        $ForcePreSharedKeyUpdate,

        [Parameter()]
        [System.String]
        $NetworkName,

        [Parameter()]
        [System.String]
        $PreSharedKey,

        [Parameter()]
        [System.String]
        $ProxyAutomaticConfigurationUrl,

        [Parameter()]
        [System.String]
        $ProxyManualAddress,

        [Parameter()]
        [System.Int32]
        $ProxyManualPort,

        [Parameter()]
        [ValidateSet('none', 'manual', 'automatic')]
        [System.String]
        $ProxySettings,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.String]
        $Ssid,

        [Parameter()]
        [ValidateSet('open', 'wpaPersonal', 'wpaEnterprise', 'wep', 'wpa2Personal', 'wpa2Enterprise')]
        [System.String]
        $WiFiSecurityType,

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

    Write-Verbose -Message "Testing configuration of the Intune Wifi Configuration Policy for iOS with Id {$Id} and DisplayName {$DisplayName}"

    if ($ProxySettings -ne 'automatic' -and $ProxyAutomaticConfigurationUrl -ne '') {
        throw 'ProxyAutomaticConfigurationUrl must be empty if ProxySettings is not "automatic".'
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($null -ne $source -and $source.GetType().Name -like '*CimInstance*')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-not $testResult)
            {
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }
    $ValuesToCheck.Remove('Id') | Out-Null
    $ValuesToCheck.Remove('PreSharedKey') | Out-Null

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
                $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosWiFiConfiguration'  `
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
        'ConnectAutomatically'
        'ConnectWhenNetworkNameIsHidden'
        'DisableMacAddressRandomization'
        'NetworkName'
        'PreSharedKey'
        'ProxyAutomaticConfigurationUrl'
        'ProxyManualAddress'
        'ProxyManualPort'
        'ProxySettings'
        'Ssid'
        'WiFiSecurityType'
    )

    $results = @{
        '@odata.type' = '#microsoft.graph.iosWiFiConfiguration'
    }
    $cloneProperties = $Properties.Clone()
    foreach ($property in $cloneProperties.Keys)
    {
        if ($property -in ($additionalProperties) )
        {
            $propertyName = $property[0].ToString().ToLower() + $property.Substring(1, $property.Length - 1)
            if ($properties.$property -and $properties.$property.GetType().FullName -like '*CIMInstance*')
            {
                if ($properties.$property.GetType().FullName -like '*[[\]]')
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
