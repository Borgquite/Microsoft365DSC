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
        $Id,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CallbackConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ClientConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $EndpointConfiguration,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
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
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Id -ne $Id)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters | Out-Null

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

            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $Id
            }
            if ($null -eq $instance)
            {
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'"
            }
        }
        else
        {
            $instance = $Script:exportedInstance
        }

        if ($null -eq $instance)
        {
            return $nullResult
        }

        # Callback Configuration
        $CallbackConfigurationValue = $null
        if ($null -ne $instance.CallbackConfiguration.TimeoutDuration)
        {
            $CallbackConfigurationValue = @{
                TimeoutDuration = "PT$($instance.CallbackConfiguration.TimeoutDuration.Minutes.ToString())M"
                AuthorizedApps  = @()
            }

            foreach ($app in $instance.CallbackConfiguration.AdditionalProperties.authorizedApps)
            {
                $appInstance = Get-MgApplication -Filter "AppId eq '$($app['id'])'" -ErrorAction SilentlyContinue
                if ($null -ne $appInstance)
                {
                    $CallbackConfigurationValue.AuthorizedApps += $appInstance.DisplayName
                }
            }
        }

        # Client Configuration
        $ClientConfigurationValue = @{
            MaximumRetries        = $instance.ClientConfiguration.MaximumRetries
            TimeoutInMilliseconds = $instance.ClientConfiguration.TimeoutInMilliseconds
        }

        # EndpointConfiguration
        $EndpointConfigurationValue = @{
            SubscriptionId       = $instance.EndpointConfiguration.AdditionalProperties.subscriptionId
            resourceGroupName    = $instance.EndpointConfiguration.AdditionalProperties.resourceGroupName
            logicAppWorkflowName = $instance.EndpointConfiguration.AdditionalProperties.logicAppWorkflowName
            url                  = $instance.EndpointConfiguration.AdditionalProperties.url
        }

        $results = @{
            DisplayName           = $DisplayName
            Id                    = $instance.Id
            Description           = $instance.Description
            CallbackConfiguration = $CallbackConfigurationValue
            ClientConfiguration   = $ClientConfigurationValue
            EndpointConfiguration = $EndpointConfigurationValue
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }
        return [System.Collections.Hashtable] $results
    }
    catch
    {
        Write-Verbose -Message $_
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
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CallbackConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ClientConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $EndpointConfiguration,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
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

    $instanceParams = @{
        displayName                 = $DisplayName
        description                 = $Description
        endpointConfiguration       = @{
            '@odata.type'        = '#microsoft.graph.logicAppTriggerEndpointConfiguration'
            subscriptionId       = $EndpointConfiguration.subscriptionId
            resourceGroupName    = $EndpointConfiguration.resourceGroupName
            logicAppWorkflowName = $EndpointConfiguration.logicAppWorkflowName
            url                  = $EndpointConfiguration.url
        }
        clientConfiguration         = @{
            '@odata.type'         = '#microsoft.graph.customExtensionClientConfiguration'
            maximumRetries        = $clientConfiguration.maximumRetries
            timeoutInMilliseconds = $clientConfiguration.timeoutInMilliseconds
        }
        authenticationConfiguration = @{
            '@odata.type' = '#microsoft.graph.azureAdPopTokenAuthentication'
        }
    }

    if ($null -ne $CallbackConfiguration)
    {
        $instanceParams.Add('callbackConfiguration', @{
                '@odata.type'   = '#microsoft.graph.identityGovernance.customTaskExtensionCallbackConfiguration'
                timeoutDuration = $CallbackConfiguration.timeoutDuration
            })

        if ($null -ne $CallbackConfiguration.AuthorizedApps)
        {
            $appsValue = @()
            foreach ($app in $CallbackConfiguration.AuthorizedApps)
            {
                $appInfo = Get-MgApplication -Filter "DisplayName eq '$($app -replace "'", "''")'" -ErrorAction SilentlyContinue
                if ($null -ne $appInfo)
                {
                    $appsValue += $appInfo.Id
                }
            }
            $instanceParams.callbackConfiguration.Add('authorizedApps', $appsValue)
        }
    }

    # CREATE
    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Workflow Custom Task Extension {$DisplayName} with parameters:`r`n$(ConvertTo-Json $instanceParams)"
        New-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -BodyParameter $instanceParams
    }
    # UPDATE
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating Workflow Custom Task Extension {$DisplayName} with parameters:`r`n$(ConvertTo-Json $instanceParams)"
        Update-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $currentInstance.Id -BodyParameter $instanceParams
    }
    # REMOVE
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Workflow Custom Task Extension {$DisplayName}"
        Remove-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $currentInstance.Id
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
        $DisplayName,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $CallbackConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ClientConfiguration,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $EndpointConfiguration,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
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

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testTargetResource = $true

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"
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
                Write-Verbose "TestResult returned False for $source"
                $testTargetResource = $false
            }
            else
            {
                $ValuesToCheck.Remove($key) | Out-Null
            }
        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    if (-not $TestResult)
    {
        $testTargetResource = $false
    }
    Write-Verbose -Message "Test-TargetResource returned $testTargetResource"
    return $testTargetResource
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
        [array] $Script:exportedInstances = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -ErrorAction Stop

        $i = 1
        $dscContent = ''
        if ($Script:exportedInstances.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($config in $Script:exportedInstances)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = $config.DisplayName
            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $displayedKey" -DeferWrite
            $params = @{
                DisplayName           = $config.DisplayName
                Id                    = $config.Id
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
            if ($null -ne $Results.EndpointConfiguration)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.EndpointConfiguration `
                    -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.EndpointConfiguration = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('EndpointConfiguration') | Out-Null
                }
            }

            if ($null -ne $Results.ClientConfiguration)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.ClientConfiguration `
                    -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.ClientConfiguration = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('ClientConfiguration') | Out-Null
                }
            }

            if ($null -ne $Results.CallbackConfiguration)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.CallbackConfiguration `
                    -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.CallbackConfiguration = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('CallbackConfiguration') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('EndpointConfiguration', 'ClientConfiguration', 'CallbackConfiguration')

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
        if ($_.ErrorDetails.Message -like "Insufficient license *")
        {
            Write-M365DSCHost -Message "`r`n    " -DeferWrite
            Write-M365DSCHost -Message $Global:M365DSCEmojiYellowCircle -DeferWrite
            Write-M365DSCHost -Message " Insufficient license. You need the Entra ID Governance license." -CommitWrite
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
