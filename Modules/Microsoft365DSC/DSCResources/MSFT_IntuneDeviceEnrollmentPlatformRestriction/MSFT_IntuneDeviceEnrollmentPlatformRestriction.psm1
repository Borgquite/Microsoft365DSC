function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
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
        [ValidateSet('singlePlatformRestriction', 'platformRestrictions')]
        [System.String]
        $DeviceEnrollmentConfigurationType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $IosRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsHomeSkuRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsMobileRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidForWorkRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacOSRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.Int32]
        $Priority,

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

    Write-Verbose -Message "Getting configuration of the Intune Device Enrollment Restriction with Id {$Identity} and DisplayName {$DisplayName}"

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

            $PlatformType = ''
            $keys = (([Hashtable]$PSBoundParameters).Clone()).Keys
            foreach ($key in $keys)
            {
                if ($null -ne $PSBoundParameters.$key -and $PSBoundParameters.$key.GetType().Name -like '*cimInstance*' -and $key -like '*Restriction')
                {
                    if ($DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' )
                    {
                        $PlatformType = $key.Replace('Restriction', '')
                        break
                    }
                }
            }

            $config = $null
            if (-not [string]::IsNullOrEmpty($Identity))
            {
                $config = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $Identity -ErrorAction SilentlyContinue
            }

            if ($null -eq $config)
            {
                Write-Verbose -Message "Could not find an Intune Device Enrollment Platform Restriction with Id {$Identity}"
                $config = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -All -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                    -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                    $_.AdditionalProperties.'@odata.type' -like '#microsoft.graph.deviceEnrollmentPlatformRestriction*Configuration' -and
                    $(if ($null -ne $_.AdditionalProperties.platformType)
                        {
                            $_.AdditionalProperties.platformType -eq $PlatformType
                        }
                        else
                        {
                            $true
                        })
                }

                if ($null -eq $config)
                {
                    Write-Verbose -Message "Could not find an Intune Device Enrollment Platform Restriction with DisplayName {$DisplayName}"
                    return $nullResult
                }
            }
        }
        else
        {
            $config = $Script:exportedInstance
        }

        Write-Verbose -Message "Found Intune Device Enrollment Platform Restriction with Name {$($config.DisplayName)}"
        $results = @{
            Identity                          = $config.Id
            DisplayName                       = $config.DisplayName
            Description                       = $config.Description
            RoleScopeTagIds                   = $config.RoleScopeTagIds
            DeviceEnrollmentConfigurationType = $config.DeviceEnrollmentConfigurationType.ToString()
            Priority                          = $config.Priority
            Ensure                            = 'Present'
            Credential                        = $Credential
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            ApplicationSecret                 = $ApplicationSecret
            CertificateThumbprint             = $CertificateThumbprint
            ManagedIdentity                   = $ManagedIdentity.IsPresent
            AccessTokens                      = $AccessTokens
        }

        $results += Get-DevicePlatformRestrictionSetting -Properties $config.AdditionalProperties

        if ($null -ne $results.WindowsMobileRestriction)
        {
            $results.Remove('WindowsMobileRestriction') | Out-Null
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceEnrollmentConfigurationAssignment -DeviceEnrollmentConfigurationId $config.Id
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
        [Parameter(Mandatory = $true)]
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
        [ValidateSet('singlePlatformRestriction', 'platformRestrictions')]
        [System.String]
        $DeviceEnrollmentConfigurationType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $IosRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsHomeSkuRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsMobileRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidForWorkRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacOSRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.Int32]
        $Priority,

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

    if ($Ensure -eq 'Absent' -and $Identity -like '*_DefaultPlatformRestrictions')
    {
        throw 'Cannot delete the default platform restriction policy.'
    }

    $currentInstance = Get-TargetResource @PSBoundParameters
    $PSBoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters
    $PSBoundParameters.Remove('Identity') | Out-Null
    $PriorityPresent = $false
    if ($PSBoundParameters.Keys.Contains('Priority'))
    {
        $PriorityPresent = $true
        $PSBoundParameters.Remove('Priority') | Out-Null
    }

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Device Enrollment Platform Restriction with DisplayName {$DisplayName}"

        $PSBoundParameters.Remove('Assignments') | Out-Null

        if ($PSBoundParameters.Keys.Contains('WindowsMobileRestriction'))
        {
            if ($WindowsMobileRestriction.platformBlocked -eq $false)
            {
                Write-Verbose -Message 'Windows Mobile platform is deprecated and cannot be unblocked, reverting back to blocked'
                $WindowsMobileRestriction.platformBlocked = $true
            }
        }

        $keys = (([Hashtable]$PSBoundParameters).Clone()).Keys
        foreach ($key in $keys)
        {
            $keyName = $key.Substring(0, 1).ToLower() + $key.Substring(1, $key.Length - 1)
            $keyValue = $PSBoundParameters.$key
            if ($null -ne $PSBoundParameters.$key -and $PSBoundParameters.$key.GetType().Name -like '*cimInstance*')
            {
                $keyValue = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $PSBoundParameters.$key
                if ($DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' )
                {
                    $keyName = 'platformRestriction'
                    $PSBoundParameters.Add('platformType', ($key.Replace('Restriction', '')))
                }
            }
            $PSBoundParameters.Remove($key)
            $PSBoundParameters.Add($keyName, $keyValue)
        }

        $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
        if ($DeviceEnrollmentConfigurationType -eq 'platformRestrictions' )
        {
            $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration'
            $PSBoundParameters.Add('deviceEnrollmentConfigurationType ', 'limit')
        }
        $PSBoundParameters.Add('@odata.type', $policyType)

        #Write-Verbose ($PSBoundParameters | ConvertTo-Json -Depth 20)

        $policy = New-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
            -BodyParameter ([hashtable]$PSBoundParameters)

        # Assignments from DefaultPolicy are not editable and will raise an alert
        if ($policy.Id -notlike '*_DefaultPlatformRestrictions')
        {
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceEnrollmentConfigurations' `
                -RootIdentifier 'enrollmentConfigurationAssignments'

            if ($PriorityPresent -and $Priority -ne $policy.Priority)
            {
                $Uri = '/beta/deviceManagement/deviceEnrollmentConfigurations/{0}/setPriority' -f $policy.Id
                $Body = @{
                    priority = $Priority
                }
                Invoke-MgGraphRequest -Method POST -Uri $Uri -Body $Body
            }
        }
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Intune Device Enrollment Platform Restriction with DisplayName {$DisplayName}"

        $PSBoundParameters.Remove('Assignments') | Out-Null

        if ($PSBoundParameters.Keys.Contains('WindowsMobileRestriction'))
        {
            if ($WindowsMobileRestriction.platformBlocked -eq $false)
            {
                Write-Verbose -Message 'Windows Mobile platform is deprecated and cannot be unblocked, reverting back to blocked'
                $WindowsMobileRestriction.platformBlocked = $true
            }
        }

        $keys = (([Hashtable]$PSBoundParameters).Clone()).Keys
        foreach ($key in $keys)
        {
            $keyName = $key.Substring(0, 1).ToLower() + $key.Substring(1, $key.Length - 1)
            $keyValue = $PSBoundParameters.$key
            if ($null -ne $PSBoundParameters.$key -and $PSBoundParameters.$key.GetType().Name -like '*cimInstance*')
            {
                $keyValue = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $PSBoundParameters.$key
                if ($DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' )
                {
                    $keyName = 'platformRestriction'
                }
            }
            $PSBoundParameters.Remove($key)
            $PSBoundParameters.Add($keyName, $keyValue)
        }

        $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
        if ($DeviceEnrollmentConfigurationType -eq 'platformRestrictions' )
        {
            $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration'
        }
        $PSBoundParameters.Add('@odata.type', $policyType)

        Write-Verbose "Updating with values:`r`n$($PSBoundParameters | ConvertTo-Json -Depth 20)"

        Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
            -DeviceEnrollmentConfigurationId $currentInstance.Identity `
            -BodyParameter ([hashtable]$PSBoundParameters)

        # Assignments from DefaultPolicy are not editable and will raise an alert
        if ($currentInstance.Identity -notlike '*_DefaultPlatformRestrictions')
        {
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Identity `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceEnrollmentConfigurations' `
                -RootIdentifier 'enrollmentConfigurationAssignments'

            if ($PriorityPresent -and $Priority -ne $currentInstance.Priority)
            {
                $Uri = '/beta/deviceManagement/deviceEnrollmentConfigurations/{0}/setPriority' -f $currentInstance.Identity
                $Body = @{
                    priority = $Priority
                }
                Invoke-MgGraphRequest -Method POST -Uri $Uri -Body $Body
            }
        }
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing the Intune Device Enrollment Platform Restriction with DisplayName {$DisplayName}"
        Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $currentInstance.Identity
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
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
        [ValidateSet('singlePlatformRestriction', 'platformRestrictions')]
        [System.String]
        $DeviceEnrollmentConfigurationType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $IosRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsHomeSkuRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $WindowsMobileRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AndroidForWorkRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $MacOSRestriction,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.Int32]
        $Priority,

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
    Write-Verbose -Message "Testing configuration of the Intune Device Enrollment Platform Restriction with Id {$Identity} and DisplayName {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($source.GetType().Name -like '*CimInstance*' -and $key -ne 'WindowsMobileRestriction')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-not $testResult)
            {
                $testResult = $false
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck
    $ValuesToCheck.Remove('Identity') | Out-Null
    $ValuesToCheck.Remove('WindowsMobileRestriction') | Out-Null

    #Convert any DateTime to String
    foreach ($key in $ValuesToCheck.Keys)
    {
        if (($null -ne $CurrentValues[$key]) `
                -and ($CurrentValues[$key].GetType().Name -eq 'DateTime'))
        {
            $CurrentValues[$key] = $CurrentValues[$key].ToString()
        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    #Compare basic parameters
    if ($testResult)
    {
        Write-Verbose -Message 'Comparing the current values with the desired ones'
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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        [array]$configs = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Filter $Filter -All `
            -ErrorAction Stop | Where-Object -FilterScript { $_.DeviceEnrollmentConfigurationType -like '*platformRestriction*' }

        $i = 1
        $dscContent = ''
        if ($configs.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($config in $configs)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($configs.Count)] $($config.displayName)" -DeferWrite
            $params = @{
                Identity              = $config.id
                DisplayName           = $config.displayName
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
            if ($null -ne $Results.Assignments)
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

            if ($null -ne $Results.IosRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.IosRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.IosRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('IosRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.WindowsRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.WindowsRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('WindowsRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.WindowsHomeSkuRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsHomeSkuRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.WindowsHomeSkuRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('WindowsHomeSkuRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.WindowsMobileRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsMobileRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.WindowsMobileRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('WindowsMobileRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.AndroidRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.AndroidRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.AndroidRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AndroidRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.AndroidForWorkRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.AndroidForWorkRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.AndroidForWorkRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AndroidForWorkRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.MacRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.MacRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.MacRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('MacRestriction') | Out-Null
                }
            }

            if ($null -ne $Results.MacOSRestriction)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.MacOSRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                if ($complexTypeStringResult)
                {
                    $Results.MacOSRestriction = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('MacOSRestriction') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Assignments', 'IosRestriction', 'WindowsRestriction', 'WindowsHomeSkuRestriction',
                    'WindowsMobileRestriction', 'AndroidRestriction', 'AndroidForWorkRestriction',
                    'MacRestriction','MacOSRestriction')

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

function Get-DevicePlatformRestrictionSetting
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties
    )

    $results = @{}

    if ($null -ne $Properties.platformType)
    {
        $keyName = ($Properties.platformType).Substring(0, 1).ToUpper() + ($Properties.platformType).Substring(1, $Properties.platformType.length - 1) + 'Restriction'
        $keyValue = [Hashtable]::new($Properties.platformRestriction)
        $hash = @{}
        foreach ($key in $keyValue.Keys)
        {
            if ($null -ne $keyValue.$key)
            {
                switch -Wildcard ($keyValue.$key.GetType().name)
                {
                    '*[[\]]'
                    {
                        if ($keyValue.$key.count -gt 0)
                        {
                            $hash.Add($key, $keyValue.$key)
                        }
                    }
                    'String'
                    {
                        if (-Not [String]::IsNullOrEmpty($keyValue.$key))
                        {
                            $hash.Add($key, $keyValue.$key)
                        }
                    }
                    Default
                    {
                        $hash.Add($key, $keyValue.$key)
                    }
                }
            }
        }
        $results.Add($keyName, $hash)
    }
    else
    {
        $platformRestrictions = [Hashtable]::new($Properties)
        $platformRestrictions.Remove('@odata.type')
        $platformRestrictions.Remove('@odata.context')
        foreach ($key in $platformRestrictions.Keys)
        {
            $keyName = $key.Substring(0, 1).ToUpper() + $key.Substring(1, $key.Length - 1)
            $keyValue = [Hashtable]::new($platformRestrictions.$key)
            $hash = @{}
            foreach ($key in $keyValue.Keys)
            {
                if ($null -ne $keyValue.$key)
                {
                    switch -Wildcard ($keyValue.$key.GetType().name)
                    {
                        '*[[\]]'
                        {
                            if ($keyValue.$key.count -gt 0)
                            {
                                $hash.Add($key, $keyValue.$key)
                            }
                        }
                        'String'
                        {
                            if (-Not [String]::IsNullOrEmpty($keyValue.$key))
                            {
                                $hash.Add($key, $keyValue.$key)
                            }
                        }
                        Default
                        {
                            $hash.Add($key, $keyValue.$key)
                        }
                    }

                }
            }
            $results.Add($keyName, $hash)
        }
    }

    return $results
}

Export-ModuleMember -Function *-TargetResource
