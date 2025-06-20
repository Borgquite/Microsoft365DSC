function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 49)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateLength(1, 512)]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $NormalizationRules,

        [Parameter()]
        [System.String]
        $ExternalAccessPrefix,

        [Parameter()]
        [System.Boolean]
        $OptimizeDeviceDialing = $false,

        [Parameter()]
        [ValidateLength(1, 49)]
        [System.String]
        $SimpleName,

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

    Write-Verbose -Message 'Getting configuration of Teams Tenant Dial Plan'

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Identity -ne $Identity)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
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

            $nullReturn = $PSBoundParameters
            $nullReturn.Ensure = 'Absent'

            $config = Get-CsTenantDialPlan -Identity $Identity -ErrorAction 'SilentlyContinue'
        }
        else
        {
            $config = $Script:exportedInstance
        }

        if ($null -eq $config)
        {
            Write-Verbose -Message "Could not find existing Dial Plan {$Identity}"
            return $nullReturn
        }

        Write-Verbose -Message "Found existing Dial Plan {$Identity}"
        $rules = @()
        if ($config.NormalizationRules.Count -gt 0)
        {
            $rules = Get-M365DSCNormalizationRules -Rules $config.NormalizationRules
        }

        $result = @{
            Identity              = $Identity.Replace('Tag:', '')
            Description           = $config.Description
            NormalizationRules    = $rules
            SimpleName            = $config.SimpleName
            Credential            = $Credential
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }

        return $result
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
        [ValidateLength(1, 49)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateLength(1, 512)]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $NormalizationRules,

        [Parameter()]
        [System.String]
        $ExternalAccessPrefix,

        [Parameter()]
        [System.Boolean]
        $OptimizeDeviceDialing = $false,

        [Parameter()]
        [ValidateLength(1, 49)]
        [System.String]
        $SimpleName,

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

    Write-Verbose -Message 'Setting configuration of Teams Guest Calling'

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
    $PSBoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters
    if ($PSBoundParameters.ContainsKey('OptimizeDeviceDialing'))
    {
        $PSBoundParameters.Remove('OptimizeDeviceDialing') | Out-Null

        Write-Verbose -Message 'Parameter OptimizeDeviceDialing has been deprecated and must not be used, removing it from PSBoundParameters.'
    }
    if ($PSBoundParameters.ContainsKey('ExternalAccessPrefix'))
    {
        $PSBoundParameters.Remove('ExternalAccessPrefix') | Out-Null

        Write-Verbose -Message 'Parameter ExternalAccessPrefix has been deprecated and must not be used, removing it from PSBoundParameters.'
    }

    if ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
    {
        Write-Verbose "Tenant Dial Plan {$Identity} doesn't exist but it should. Creating it."
        #region VoiceNormalizationRules
        $AllRules = @()
        # Ensure the VoiceNormalizationRules all exist
        foreach ($rule in $NormalizationRules)
        {
            # Need to create the rule
            Write-Verbose "Creating VoiceNormalizationRule {$($rule.Identity)}"
            $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($rule.Identity.Replace('Tag:', ''))" `
                -Description $rule.Description `
                -Pattern $rule.Pattern `
                -Translation $rule.Translation `
                -InMemory

            $AllRules += $ruleObject
        }

        $PSBoundParameters.NormalizationRules = @{ Add = $AllRules }

        New-CsTenantDialPlan @PSBoundParameters
    }
    elseif ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Tenant Dial Plan {$Identity} already exists. Updating it."

        $desiredRules = @()
        foreach ($rule in $NormalizationRules)
        {
            $desiredRule = @{
                Identity            = $rule.Identity
                Description         = $rule.Description
                Pattern             = $rule.Pattern
                IsExternalExtension = $rule.IsExternalExtension
                Translation         = $rule.Translation
            }
            $desiredRules += $desiredRule
        }

        $differences = Get-M365DSCVoiceNormalizationRulesDifference -CurrentRules $CurrentValues.NormalizationRules -DesiredRules $desiredRules

        $rulesToRemove = @()
        $rulesToAdd = @()

        foreach ($ruleToAdd in $differences.RulesToAdd)
        {
            Write-Verbose "Adding new VoiceNormalizationRule {$($ruleToAdd.Identity)}"
            $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($ruleToAdd.Identity.Replace('Tag:', ''))" `
                -Description $ruleToAdd.Description `
                -Pattern $ruleToAdd.Pattern `
                -Translation $ruleToAdd.Translation `
                -InMemory
            Write-Verbose 'VoiceNormalizationRule created'
            Set-CsTenantDialPlan -Identity $Identity -NormalizationRules @{ Add = $ruleObject }
            Write-Verbose 'Updated the Tenant Dial Plan'
        }
        foreach ($ruleToRemove in $differences.RulesToRemove)
        {
            if ($null -eq $plan)
            {
                $plan = Get-CsTenantDialPlan -Identity $Identity
            }
            $ruleObject = $plan.NormalizationRules | Where-Object -FilterScript { $_.Name -eq $ruleToRemove.Identity }

            if ($null -ne $ruleObject)
            {
                Write-Verbose "Removing VoiceNormalizationRule {$($ruleToRemove.Identity)}"
                Write-Verbose 'VoiceNormalizationRule created'
                Set-CsTenantDialPlan -Identity $Identity -NormalizationRules @{ Remove = $ruleObject }
                Write-Verbose 'Updated the Tenant Dial Plan'
            }
        }
        foreach ($ruleToUpdate in $differences.RulesToUpdate)
        {
            if ($null -eq $plan)
            {
                $plan = Get-CsTenantDialPlan -Identity $Identity
            }
            $ruleObject = $plan.NormalizationRules | Where-Object -FilterScript { $_.Name -eq $ruleToUpdate.Identity }

            if ($null -ne $ruleObject)
            {
                Write-Verbose "Updating VoiceNormalizationRule {$($ruleToUpdate.Identity)}"
                Set-CsTenantDialPlan -Identity $Identity -NormalizationRules @{ Remove = $ruleObject }
                $ruleObject = New-CsVoiceNormalizationRule -Identity "Global/$($ruleToUpdate.Identity.Replace('Tag:', ''))" `
                    -Description $ruleToUpdate.Description `
                    -Pattern $ruleToUpdate.Pattern `
                    -Translation $ruleToUpdate.Translation `
                    -InMemory
                Write-Verbose 'VoiceNormalizationRule Updated'
                Set-CsTenantDialPlan -Identity $Identity -NormalizationRules @{ Add = $ruleObject }
                Write-Verbose 'Updated the Tenant Dial Plan'
            }
        }
    }
    elseif ($Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Tenant Dial Plan {$Identity} exists and shouldn't. Removing it."
        Remove-CsTenantDialPlan -Identity $Identity
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 49)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateLength(1, 512)]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $NormalizationRules,

        [Parameter()]
        [System.String]
        $ExternalAccessPrefix,

        [Parameter()]
        [System.Boolean]
        $OptimizeDeviceDialing = $false,

        [Parameter()]
        [ValidateLength(1, 49)]
        [System.String]
        $SimpleName,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message 'Testing configuration of Teams Guest Calling'

    $CurrentValues = Get-TargetResource @PSBoundParameters
    if ($PSBoundParameters.ContainsKey('OptimizeDeviceDialing'))
    {
        $PSBoundParameters.Remove('OptimizeDeviceDialing') | Out-Null

        Write-Verbose -Message 'Parameter OptimizeDeviceDialing has been deprecated and must not be used, removing it from PSBoundParameters.'
    }
    if ($PSBoundParameters.ContainsKey('ExternalAccessPrefix'))
    {
        $PSBoundParameters.Remove('ExternalAccessPrefix') | Out-Null

        Write-Verbose -Message 'Parameter ExternalAccessPrefix has been deprecated and must not be used, removing it from PSBoundParameters.'
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    if ($null -ne $NormalizationRules)
    {
        $desiredRules = @()
        foreach ($rule in $NormalizationRules)
        {
            $desiredRule = @{
                Identity            = $rule.Identity
                Description         = $rule.Description
                Pattern             = $rule.Pattern
                IsExternalExtension = $rule.IsExternalExtension
                Translation         = $rule.Translation
            }
            $desiredRules += $desiredRule
        }

        if (-not $null -eq $CurrentValues.NormalizationRules)
        {
            $differences = Get-M365DSCVoiceNormalizationRulesDifference -CurrentRules $CurrentValues.NormalizationRules `
                -DesiredRules $desiredRules
        }
        elseif ($NormalizationRules.Length -gt 0)
        {
            return $false
        }
    }

    if ($differences.RulesToAdd.Length -gt 0 -or $differences.RulesToUpdate.Length -gt 0 -or $differences.RulesToRemove.Length -gt 0)
    {
        return $false
    }

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('NormalizationRules') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

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
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
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
        [array]$tenantDialPlans = Get-CsTenantDialPlan -ErrorAction Stop

        $dscContent = ''
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        foreach ($plan in $tenantDialPlans)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($tenantDialPlans.Count)] $($plan.Identity)" -DeferWrite
            $params = @{
                Identity              = $plan.Identity
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $plan
            $Results = Get-TargetResource @Params

            if ($null -ne $Results.NormalizationRules)
            {
                $complexMapping = @(
                    @{
                        Name            = 'NormalizationRules'
                        CimInstanceName = 'TeamsVoiceNormalizationRule'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.NormalizationRules `
                    -CIMInstanceName 'TeamsVoiceNormalizationRule' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.NormalizationRules = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('NormalizationRules') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('NormalizationRules')

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

function Get-M365DSCVoiceNormalizationRulesDifference
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.Object[]]
        $CurrentRules,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $DesiredRules
    )

    $differences = @{}
    $rulesToRemove = @()
    $rulesToAdd = @()
    $rulesToUpdate = @()
    foreach ($currentRule in $CurrentRules)
    {
        $equivalentDesiredRule = $DesiredRules | Where-Object -FilterScript { $_.Identity -eq $currentRule.Identity }

        # Case the current rule is not listed in the Desired rules, we need to remove it
        if ($null -eq $equivalentDesiredRule)
        {
            Write-Verbose "Adding Rule {$($currentRule.Identity)} to the RulesToRemove"
            $rulesToRemove += $currentRule
        }
        # Case the rule exists but is not in the desired state
        else
        {
            $differenceFound = $false
            foreach ($key in $currentRule.Keys)
            {
                if (-not [System.String]::IsNullOrEmpty($equivalentDesiredRule.$key) -and $currentRule.$key -ne $equivalentDesiredRule.$key)
                {
                    $differenceFound = $true
                }
            }

            if ($differenceFound)
            {
                Write-Verbose "Adding Rule {$($currentRule.Identity)} to the RulesToUpdate"
                $rulesToUpdate += $equivalentDesiredRule
            }
        }
    }

    foreach ($desiredRule in $DesiredRules)
    {
        $equivalentCurrentRule = $CurrentRules | Where-Object -FilterScript { $_.Identity -eq $desiredRule.Identity }

        # Case the desired rule doesn't exist, we need to create it
        if ($null -eq $equivalentCurrentRule)
        {
            Write-Verbose "Adding Rule {$($desiredRule.Identity)} to the RulesToAdd"
            $rulesToAdd += $desiredRule
        }
    }
    $differences.Add('RulesToAdd', $rulesToAdd)
    $differences.Add('RulesToUpdate', $rulesToUpdate)
    $differences.Add('RulesToRemove', $rulesToRemove)
    return $differences
}

function Get-M365DSCNormalizationRules
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        $Rules
    )

    if ($null -eq $Rules)
    {
        return $null
    }

    $result = @()
    foreach ($rule in $Rules)
    {
        $ruleName = $rule.Name.Replace('Tag:', '')
        $currentRule = @{
            Identity            = $ruleName
            Priority            = $rule.Priority
            Description         = $rule.Description
            Pattern             = $rule.Pattern
            Translation         = $rule.Translation
            IsInternalExtension = $rule.IsInternalExtension
        }
        if ([System.String]::IsNullOrEmpty($rule.Priority))
        {
            $currentRule.Remove('Priority') | Out-Null
        }
        $result += $currentRule
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
