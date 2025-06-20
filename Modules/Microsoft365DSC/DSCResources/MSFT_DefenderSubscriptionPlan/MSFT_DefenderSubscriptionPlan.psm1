function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SubscriptionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PlanName,

        [Parameter()]
        [System.String]
        $SubscriptionId,

        [Parameter()]
        [ValidateSet('Free', 'Standard')]
        [System.String]
        $PricingTier,

        [Parameter()]
        [System.String]
        $SubPlanName,

        [Parameter()]
        [System.String]
        $Extensions,

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
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Id -ne $SubscriptionId)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'Azure' `
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

            if ([System.String]::IsNullOrEmpty($subscriptionId))
            {
                $subscription = Get-AzSubscription -SubscriptionName $SubscriptionName

                if ($null -ne $subscription)
                {
                    $subscriptionId = $subscription.Id
                }
            }

            if ($null -ne $subscriptionId)
            {
                Set-AzContext -Subscription $subscriptionId -ErrorAction Stop
                $instance = Get-AzSecurityPricing -Name $PlanName -ErrorAction Stop
                $azContext = Get-AzContext
                Add-Member -InputObject $instance -NotePropertyName 'SubscriptionName' -NotePropertyValue $azContext.Subscription.Name
                Add-Member -InputObject $instance -NotePropertyName 'SubscriptionId' -NotePropertyValue $azContext.Subscription.Id
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

        $results = @{
            SubscriptionId        = $instance.SubscriptionId
            SubscriptionName      = $instance.SubscriptionName
            PlanName              = $PlanName
            PricingTier           = $instance.PricingTier
            SubPlanName           = $instance.SubPlan
            Extensions            = $instance.Extensions
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
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
        $SubscriptionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PlanName,

        [Parameter()]
        [System.String]
        $SubscriptionId,

        [Parameter()]
        [ValidateSet('Free', 'Standard')]
        [System.String]
        $PricingTier,

        [Parameter()]
        [System.String]
        $SubPlanName,

        [Parameter()]
        [System.String]
        $Extensions,

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

    $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    # CREATE
    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        throw "It's not possible to create Microsoft Defender for Cloud bundles"
    }
    # UPDATE
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Set-AzContext -Subscription $currentInstance.SubscriptionId -ErrorAction Stop
        if ($Extensions)
        {
            Set-AzSecurityPricing -Name $PlanName -PricingTier $PricingTier -SubPlan $SubPlanName -Extension $Extensions -ErrorAction Stop
        }
        else
        {
            Set-AzSecurityPricing -Name $PlanName -PricingTier $PricingTier -SubPlan $SubPlanName -ErrorAction Stop
        }
    }
    # REMOVE
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        throw "It's not possible to delete Microsoft Defender for Cloud bundles"
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
        $SubscriptionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PlanName,

        [Parameter()]
        [System.String]
        $SubscriptionId,

        [Parameter()]
        [ValidateSet('Free', 'Standard')]
        [System.String]
        $PricingTier,

        [Parameter()]
        [System.String]
        $SubPlanName,

        [Parameter()]
        [System.String]
        $Extensions,

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

    $ConnectionMode = New-M365DSCConnection -Workload 'Azure' `
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
        [array] $Script:exportedInstances = Get-SubscriptionsDefenderPlansFromArg -ErrorAction Stop

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
            $displayedKey = $config.Id
            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $displayedKey" -DeferWrite
            $params = @{
                SubscriptionName      = $config.SubscriptionName
                SubscriptionId        = $config.SubscriptionId
                PlanName              = $config.PlanName
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $config
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
        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

        New-M365DSCLogEntry -Message 'Error during Export:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return ''
    }
}


function Get-SubscriptionsDefenderPlansFromArg
{
    try
    {
        $results = @()
        $argQuery = @'
securityresources | where type == "microsoft.security/pricings" | project Id=id, PlanName=name, SubscriptionId=subscriptionId, SubPlan=tostring(properties.subPlan), PricingTier=tostring(properties.pricingTier), Extensions=tostring(properties.extensions)
| join kind=inner (resourcecontainers | where type == "microsoft.resources/subscriptions" | project SubscriptionName = name, SubscriptionId = subscriptionId) on SubscriptionId | project-away SubscriptionId1
'@
        $queryResult = Search-AzGraph -Query $argQuery -First 1000 -UseTenantScope -ErrorAction Stop
        $results += $queryResult.Data

        while ($queryResult.SkipToken -ne $null)
        {
            $queryResult = Search-AzGraph -Query $argQuery -First 1000 -UseTenantScope -SkipToken $queryResult.SkipToken -ErrorAction Stop
            $results += $queryResult.Data
        }

        return $results
    }
    catch
    {
        throw $_
    }
}


Export-ModuleMember -Function *-TargetResource
