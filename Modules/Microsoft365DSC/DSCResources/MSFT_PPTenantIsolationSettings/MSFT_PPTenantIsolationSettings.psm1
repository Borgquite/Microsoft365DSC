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
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Rules,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToInclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToExclude,

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
        [System.Management.Automation.PSCredential]
        $ApplicationSecret
    )

    Write-Verbose -Message 'Getting the Power Platform Tenant Isolation Settings Configuration'

    if ($PSBoundParameters.ContainsKey('Rules') -and `
        ($PSBoundParameters.ContainsKey('RulesToInclude') -or `
                $PSBoundParameters.ContainsKey('RulesToExclude')))
    {
        $message = 'You cannot specify Rules and RulesToInclude/RulesToExclude.'
        Add-M365DSCEvent -Message $message -EntryType 'Error' `
            -EventID 1 -Source $($MyInvocation.MyCommand.Source)
        throw $message
    }

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    $tenantid = (Get-MgContext).TenantId

    $ConnectionMode = New-M365DSCConnection -Workload 'PowerPlatformREST' `
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

    $nullReturn = @{
        IsSingleInstance = 'Yes'
    }

    try
    {
        $uri = "https://" + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
               "/providers/PowerPlatform.Governance/v1/tenants/$($tenantId)/tenantIsolationPolicy?api-version=2016-11-01"
        $tenantIsolationPolicy = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET' -Body $RequestBody
        if ($tenantIsolationPolicy.StatusCode -eq 403)
        {
            throw 'Invalid permission for the application. If you are using a custom app registration to authenticate, make sure it is defined as a Power Platform admin management application. For additional information refer to https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application'
        }

        [Array]$allowedTenants = $tenantIsolationPolicy.properties.allowedTenants | ForEach-Object {
            $directions = $_.direction
            if ($directions.inbound -eq $true)
            {
                if ($directions.outbound -eq $true)
                {
                    $direction = 'Both'
                }
                else
                {
                    $direction = 'Inbound'
                }
            }
            elseif ($directions.outbound -eq $true)
            {
                $direction = 'Outbound'
            }
            else
            {
                $direction = 'unknown'
            }

            return @{
                TenantName = $_.tenantId
                Direction  = $direction
            }
        }

        return @{
            IsSingleInstance      = 'Yes'
            Enabled               = ($tenantIsolationPolicy.properties.isDisabled -eq $false)
            Rules                 = $allowedTenants
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
            ApplicationSecret     = $ApplicationSecret
        }
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $nullReturn
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
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Rules,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToInclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToExclude,

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
        [System.Management.Automation.PSCredential]
        $ApplicationSecret
    )

    Write-Verbose -Message 'Setting Power Platform Tenant Isolation Settings configuration'

    if ($PSBoundParameters.ContainsKey('Rules') -and `
        ($PSBoundParameters.ContainsKey('RulesToInclude') -or `
                $PSBoundParameters.ContainsKey('RulesToExclude')))
    {
        $message = 'You cannot specify Rules and RulesToInclude/RulesToExclude.'
        Add-M365DSCEvent -Message $message -EntryType 'Error' `
            -EventID 1 -Source $($MyInvocation.MyCommand.Source)
        throw $message
    }

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

    $ConnectionMode = New-M365DSCConnection -Workload 'PowerPlatformREST' `
        -InboundParameters $PSBoundParameters

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    $tenantinfo = (Get-MgContext).TenantId

    $tenantIsolationPolicy = @{
        properties = @{
            tenantId = $tenantinfo
            isDisabled = $false
            allowedTenants = @()
        }
    }

    $tenantIsolationPolicy.Properties.isDisabled = -not $Enabled

    [Array]$existingAllowedRules = $tenantIsolationPolicy.Properties.allowedTenants

    if ($PSBoundParameters.ContainsKey('Rules'))
    {
        Write-Verbose 'Processing parameter Rules'
        foreach ($rule in $Rules)
        {
            # Check if Rules exist
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName

            $direction = @{
                inbound  = $false
                outbound = $false
            }

            $existingRule = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }
            if ($null -eq $existingRule)
            {
                Write-Verbose "Rule for $($rule.TenantName) does not exist. Adding with direction $($rule.Direction)"
                switch ($rule.Direction)
                {
                    'Inbound'
                    {
                        $direction.inbound = $true
                    }
                    'Outbound'
                    {
                        $direction.outbound = $true
                    }
                    'Both'
                    {
                        $direction.inbound = $true
                        $direction.outbound = $true
                    }
                }

                $newRule = @{
                    tenantId          = $ruleTenantId
                    direction         = $direction
                }

                $existingAllowedRules += $newRule
            }
            else
            {
                Write-Verbose "Rule for $($rule.TenantName) exists. Setting specified direction."
                switch ($rule.Direction)
                {
                    'Inbound'
                    {
                        $existingRule.Direction.inbound = $true
                        $existingRule.Direction.outbound = $false
                    }
                    'Outbound'
                    {
                        $existingRule.Direction.inbound = $false
                        $existingRule.Direction.outbound = $true
                    }
                    'Both'
                    {
                        $existingRule.Direction.inbound = $true
                        $existingRule.Direction.outbound = $true
                    }
                }
            }
        }

        $removeRules = @()
        foreach ($existingRule in $existingAllowedRules)
        {
            # Check if rules are not in the specified list
            if ($null -eq ($Rules | Where-Object -FilterScript { (Get-M365TenantId -TenantName $_.TenantName) -eq $existingRule.tenantId }))
            {
                Write-Verbose "Rule for tenant id $($existingRule.tenantId) does not exist in the Rules parameter. Deleting rule."
                $removeRules += $existingRule.tenantId
            }
        }
        [Array]$newRules = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -notin $removeRules }
        $tenantIsolationPolicy.Properties.allowedTenants = $newRules
    }

    if ($PSBoundParameters.ContainsKey('RulesToInclude'))
    {
        Write-Verbose 'Processing parameter RulesToInclude'
        foreach ($rule in $RulesToInclude)
        {
            Write-Verbose "Checking rule for TenantName $($rule.TenantName) with direction $($rule.Direction)"
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName
            Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

            $direction = [PSCustomObject]@{
                inbound  = $false
                outbound = $false
            }

            $existingRule = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }
            if ($null -eq $existingRule)
            {
                Write-Verbose "Rule does not exist. Adding with direction $($rule.Direction)"
                # Rule does not exist, add rule
                switch ($rule.Direction)
                {
                    'Inbound'
                    {
                        $direction.inbound = $true
                    }
                    'Outbound'
                    {
                        $direction.outbound = $true
                    }
                    'Both'
                    {
                        $direction.inbound = $true
                        $direction.outbound = $true
                    }
                }

                $newRule = [PSCustomObject]@{
                    tenantId          = $ruleTenantId
                    tenantDisplayName = ''
                    direction         = $direction
                }

                $existingAllowedRules += $newRule
            }
            else
            {
                Write-Verbose 'Rule exists. Setting specified direction.'
                switch ($rule.Direction)
                {
                    'Inbound'
                    {
                        $existingRule.Direction.inbound = $true
                        $existingRule.Direction.outbound = $false
                    }
                    'Outbound'
                    {
                        $existingRule.Direction.inbound = $false
                        $existingRule.Direction.outbound = $true
                    }
                    'Both'
                    {
                        $existingRule.Direction.inbound = $true
                        $existingRule.Direction.outbound = $true
                    }
                }
            }
        }
        $tenantIsolationPolicy.Properties.allowedTenants = $existingAllowedRules
    }

    if ($PSBoundParameters.ContainsKey('RulesToExclude'))
    {
        Write-Verbose 'Processing parameter RulesToExclude'
        foreach ($rule in $RulesToExclude)
        {
            Write-Verbose "Checking rule for TenantName $($rule.TenantName) RulesToExclude"
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName
            Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

            $removeRules = @()
            if ($null -ne ($existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }))
            {
                Write-Verbose "Rule for $($rule.TenantName) is currently configured in the rules. Deleting rule."
                $removeRules += $ruleTenantId
            }
        }

        [Array]$newRules = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -notin $removeRules }
        $tenantIsolationPolicy.Properties.allowedTenants = $newRules
    }
    $uri = "https://" + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
               "/providers/PowerPlatform.Governance/v1/tenants/$($tenantId)/tenantIsolationPolicy?api-version=2020-06-01"
    Write-Verbose -Message "Updating with payload:`r`n$(ConvertTo-Json $tenantIsolationPolicy -Depth 20)"
    Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'PUT' -Body $tenantIsolationPolicy
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
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Rules,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToInclude,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RulesToExclude,

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
        [System.Management.Automation.PSCredential]
        $ApplicationSecret
    )

    Write-Verbose -Message 'Testing Power Platform Tenant Isolation Settings configuration'

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

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $result = $true
    $driftedRules = @{}
    if ($PSBoundParameters.ContainsKey('Rules'))
    {
        Write-Verbose 'Processing parameter Rules'
        foreach ($rule in $Rules)
        {
            Write-Verbose "Checking Rule for TenantName $($rule.TenantName). Rules"
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName
            Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

            $existingRule = $CurrentValues.Rules | Where-Object -FilterScript { $_.TenantName -eq $ruleTenantId }
            if ($null -eq $existingRule)
            {
                Write-Verbose "Rule for $($rule.TenantName) does not exist."
                $driftedRules.($rule.TenantName) = @{
                    CurrentValue = 'Rule does not exist'
                    DesiredValue = "Direction: $($rule.Direction)"
                }
                $result = $false
            }
            else
            {
                Write-Verbose "Rule for $($rule.TenantName) exists. Checking specified direction."
                if ($rule.Direction -ne $existingRule.Direction)
                {
                    Write-Verbose "Direction for rule incorrect: Current = $($existingRule.Direction) / Desired = $($rule.Direction)"
                    $driftedRules.($rule.TenantName) = @{
                        CurrentValue = "Direction: $($existingRule.Direction)"
                        DesiredValue = "Direction: $($rule.Direction)"
                    }
                    $result = $false
                }
            }
        }

        foreach ($existingRule in $CurrentValues.Rules)
        {
            # Check if rules are not in the specified list
            if ($null -eq ($Rules | Where-Object -FilterScript { (Get-M365TenantId -TenantName $_.TenantName) -eq $existingRule.TenantName }))
            {
                Write-Verbose "Rule for tenant id $($existingRule.TenantName) does not exist in the Desired State."

                $driftedRules.($existingRule.TenantName) = @{
                    CurrentValue = "Direction: $($existingRule.Direction)"
                    DesiredValue = "Direction: $($rule.Direction)"
                }
                $result = $false
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('RulesToInclude'))
    {
        Write-Verbose 'Processing parameter RulesToInclude'
        $driftedRules = @{}
        foreach ($rule in $RulesToInclude)
        {
            Write-Verbose "Checking Rule for TenantName $($rule.TenantName). RulesToInclude"
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName
            Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

            $existingRule = $CurrentValues.Rules | Where-Object -FilterScript { $_.TenantName -eq $ruleTenantId }
            if ($null -eq $existingRule)
            {
                Write-Verbose "Rule for $($rule.TenantName) does not exist."
                $driftedRules.($rule.TenantName) = @{
                    CurrentValue = 'Rule does not exist'
                    DesiredValue = "Direction: $($rule.Direction)"
                }
                $result = $false
            }
            else
            {
                Write-Verbose "Rule for $($rule.TenantName) exists. Checking specified direction."
                if ($rule.Direction -ne $existingRule.Direction)
                {
                    Write-Verbose "Direction for rule incorrect: Current = $($existingRule.Direction) / Desired = $($rule.Direction)"
                    $driftedRules.($rule.TenantName) = @{
                        CurrentValue = "Direction: $($existingRule.Direction)"
                        DesiredValue = "Direction: $($rule.Direction)"
                    }
                    $result = $false
                }
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('RulesToExclude'))
    {
        Write-Verbose 'Processing parameter RulesToExclude'
        $driftedRules = @{}
        foreach ($rule in $RulesToExclude)
        {
            Write-Verbose "Checking Rule for TenantName $($rule.TenantName). RulesToExclude"
            $ruleTenantId = Get-M365TenantId -TenantName $rule.TenantName
            Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

            $existingRule = $CurrentValues.Rules | Where-Object -FilterScript { $_.TenantName -eq $ruleTenantId }
            if ($null -ne $existingRule)
            {
                Write-Verbose "Rule for $($rule.TenantName) exists."
                $driftedRules.($rule.TenantName) = @{
                    CurrentValue = "Direction: $($existingRule.Direction)"
                    DesiredValue = 'Should not exist'
                }
                $result = $false
            }
        }
    }

    if ($result -eq $false)
    {
        $message = "Tenant Isolation Rules not in the Desired State:`n"
        $message += "<Rules>`n"
        foreach ($driftedRule in $driftedRules.GetEnumerator())
        {
            $message += "    <Rule>`n"
            $message += "        <TenantName>$($driftedRule.Name)</TenantName>`n"
            $message += "        <CurrentValue>$($driftedRule.Value.CurrentValue)</CurrentValue>`n"
            $message += "        <DesiredValue>$($driftedRule.Value.DesiredValue)</DesiredValue>`n"
            $message += "    </Rule>`n"
        }
        $message += '</Rules>'
        Add-M365DSCEvent -Message $message -EntryType 'Error' `
            -EventID 1 -Source $($MyInvocation.MyCommand.Source)
        Write-Verbose -Message 'Test-TargetResource returned False'
        return $false
    }

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck @('Enabled')

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
        [System.Management.Automation.PSCredential]
        $ApplicationSecret
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

    try
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'PowerPlatformREST' `
            -InboundParameters $PSBoundParameters
        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
        {
            $Global:M365DSCExportResourceInstancesCount++
        }

        $dscContent = ''

        $Params = @{
            IsSingleInstance      = 'Yes'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
            ApplicationSecret     = $ApplicationSecret
        }

        $Results = Get-TargetResource @Params

        if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
        {
            if ($null -ne $Results.Rules)
            {
                $complexMapping = @(
                    @{
                        Name            = 'Rules'
                        CimInstanceName = 'MSFT_PPTenantRule'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.Rules `
                    -CIMInstanceName 'MSFT_PPTenantRule' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.Rules = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Rules') | Out-Null
                }
            }
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Rules')

            $dscContent += $currentDSCBlock

            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName

            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
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

function Get-M365TenantId
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TenantName
    )

    if ($TenantName -eq '*')
    {
        return '*'
    }

    $result = Invoke-WebRequest "https://login.windows.net/$TenantName/.well-known/openid-configuration" -UseBasicParsing
    $jsonResult = $result | ConvertFrom-Json
    return $jsonResult.token_endpoint.Split('/')[3]
}

Export-ModuleMember -Function *-TargetResource
