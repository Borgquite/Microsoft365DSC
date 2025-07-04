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
        $HostedContentFilterPolicy,

        [Parameter()]
        [System.String]
        $Comments,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $ExceptIfRecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentTo = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentToMemberOf = @(),

        [Parameter()]
        [uint32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $RecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $SentTo = @(),

        [Parameter()]
        [System.String[]]
        $SentToMemberOf = @(),

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Getting configuration of HostedContentFilterRule for [$Identity]"

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

    if ($Global:CurrentModeIsExport)
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
            -InboundParameters $PSBoundParameters `
            -SkipModuleReload $true
    }
    else
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
            -InboundParameters $PSBoundParameters
    }

    $nullReturn = $PSBoundParameters
    $nullReturn.Ensure = 'Absent'
    try
    {
        try
        {
            $HostedContentFilterRule = Get-HostedContentFilterRule -Identity $Identity -ErrorAction Stop
        }
        catch
        {
            try
            {
                Write-Verbose -Message "Couldn't find rule by ID, trying by name."
                $rules = Get-HostedContentFilterRule
                $HostedContentFilterRule = $rules | Where-Object -FilterScript { $_.Name -eq $Identity -and $_.HostedContentFilterPolicy -eq $HostedContentFilterPolicy }
            }
            catch
            {
                $Message = 'Error calling {Get-HostedContentFilterRule}'
                New-M365DSCLogEntry -Message $Message `
                    -Exception $_ `
                    -Source $MyInvocation.MyCommand.ModuleName
            }
        }
        if (-not $HostedContentFilterRule)
        {
            Write-Verbose -Message "HostedContentFilterRule $($Identity) does not exist."
            return $nullReturn
        }
        else
        {
            $result = @{
                Ensure                    = 'Present'
                Identity                  = $Identity
                HostedContentFilterPolicy = $HostedContentFilterRule.HostedContentFilterPolicy
                Comments                  = $HostedContentFilterRule.Comments
                Enabled                   = $false
                ExceptIfRecipientDomainIs = $HostedContentFilterRule.ExceptIfRecipientDomainIs
                ExceptIfSentTo            = $HostedContentFilterRule.ExceptIfSentTo
                ExceptIfSentToMemberOf    = $HostedContentFilterRule.ExceptIfSentToMemberOf
                Priority                  = $HostedContentFilterRule.Priority
                RecipientDomainIs         = $HostedContentFilterRule.RecipientDomainIs
                SentTo                    = $HostedContentFilterRule.SentTo
                SentToMemberOf            = $HostedContentFilterRule.SentToMemberOf
                Credential                = $Credential
                ApplicationId             = $ApplicationId
                CertificateThumbprint     = $CertificateThumbprint
                CertificatePath           = $CertificatePath
                CertificatePassword       = $CertificatePassword
                Managedidentity           = $ManagedIdentity.IsPresent
                TenantId                  = $TenantId
                AccessTokens              = $AccessTokens
            }

            if ('Enabled' -eq $HostedContentFilterRule.State)
            {
                # Accounts for Get-HostedContentFilterRule returning 'State' instead of 'Enabled' used by New/Set
                $result.Enabled = $true
            }
            else
            {
                $result.Enabled = $false
            }

            Write-Verbose -Message "Found HostedContentFilterRule $($Identity)"
            Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
            return $result
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
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $HostedContentFilterPolicy,

        [Parameter()]
        [System.String]
        $Comments,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $ExceptIfRecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentTo = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentToMemberOf = @(),

        [Parameter()]
        [uint32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $RecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $SentTo = @(),

        [Parameter()]
        [System.String[]]
        $SentToMemberOf = @(),

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Setting configuration of HostedContentFilterRule for $Identity"

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

    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $BoundParameters = ([System.Collections.Hashtable]$PSBoundParameters).Clone()
    $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    if ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
    {
        # Make sure that the associated Policy exists;
        $AssociatedPolicy = Get-HostedContentFilterPolicy -Identity $HostedContentFilterPolicy -ErrorAction 'SilentlyContinue'
        if ($null -eq $AssociatedPolicy)
        {
            throw "Error attempting to create EXOHostedContentFilterRule {$Identity}. The specified HostedContentFilterPolicy " + `
                "{$HostedContentFilterPolicy} doesn't exist. Make sure you either create it first or specify a valid policy."
        }

        # Make sure that the associated Policy is not Default;
        if ($AssociatedPolicy.IsDefault -eq $true )
        {
            throw "Policy $Identity is marked as the default. Creating a rule to apply the default policy is not allowed."
        }

        if ($Enabled -and ('Disabled' -eq $CurrentValues.State))
        {
            # New-HostedContentFilterRule has the Enabled parameter, Set-HostedContentFilterRule does not.
            # There doesn't appear to be any way to change the Enabled state of a rule once created.
            Write-Verbose -Message "Removing HostedContentFilterRule {$Identity} in order to change Enabled state."
            Remove-HostedContentFilterRule -Identity $Identity -Confirm:$false
        }
        Write-Verbose -Message "Creating new HostedContentFilterRule {$Identity}"
        Write-Verbose -Message "With Parameters: $(Convert-M365DscHashtableToString -Hashtable $BoundParameters)"
        $BoundParameters.Add('Name', $Identity)
        $BoundParameters.Remove('Identity') | Out-Null
        New-HostedContentFilterRule @BoundParameters
    }
    elseif ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
    {
        # Make sure that the associated Policy exists;
        $AssociatedPolicy = Get-HostedContentFilterPolicy -Identity $HostedContentFilterPolicy -ErrorAction 'SilentlyContinue'
        if ($null -eq $AssociatedPolicy)
        {
            throw "Error attempting to create EXOHostedContentFilterRule {$Identity}. The specified HostedContentFilterPolicy " + `
                "{$HostedContentFilterPolicy} doesn't exist. Make sure you either create it first or specify a valid policy."
        }

        # Make sure that the associated Policy is not Default;
        if ($AssociatedPolicy.IsDefault -eq $true )
        {
            throw "Policy $Identity is marked as the default. Creating a rule to apply the default policy is not allowed."
        }

        $BoundParameters.Remove('Enabled') | Out-Null
        if ($CurrentValues.HostedContentFilterPolicy -eq $BoundParameters.HostedContentFilterPolicy)
        {
            $BoundParameters.Remove('HostedContentFilterPolicy') | Out-Null
        }
        Write-Verbose -Message "Updating HostedContentFilterRule {$Identity}"
        Set-HostedContentFilterRule @BoundParameters
    }
    elseif ($Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing existing HostedContentFilterRule {$Identity}."
        Remove-HostedContentFilterRule -Identity $Identity -Confirm:$false
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
        $HostedContentFilterPolicy,

        [Parameter()]
        [System.String]
        $Comments,

        [Parameter()]
        [System.Boolean]
        $Enabled = $true,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $ExceptIfRecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentTo = @(),

        [Parameter()]
        [System.String[]]
        $ExceptIfSentToMemberOf = @(),

        [Parameter()]
        [uint32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $RecipientDomainIs = @(),

        [Parameter()]
        [System.String[]]
        $SentTo = @(),

        [Parameter()]
        [System.String[]]
        $SentToMemberOf = @(),

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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

    Write-Verbose -Message "Testing configuration of HostedContentFilterRule for $Identity"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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

    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters `
        -SkipModuleReload $true

    try
    {
        [array] $HostedContentFilterRules = Get-HostedContentFilterRule -ErrorAction Stop
        $dscContent = ''

        $i = 1
        if ($HostedContentFilterRules.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($HostedContentFilterRule in $HostedContentFilterRules)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($HostedContentFilterRules.Count)] $($HostedContentFilterRule.Identity)" -DeferWrite
            $Params = @{
                Credential                = $Credential
                Identity                  = $HostedContentFilterRule.Identity
                HostedContentFilterPolicy = $HostedContentFilterRule.HostedContentFilterPolicy
                ApplicationId             = $ApplicationId
                TenantId                  = $TenantId
                CertificateThumbprint     = $CertificateThumbprint
                CertificatePassword       = $CertificatePassword
                Managedidentity           = $ManagedIdentity.IsPresent
                CertificatePath           = $CertificatePath
                AccessTokens              = $AccessTokens
            }
            $Results = Get-TargetResource @Params
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
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
        Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

        New-M365DSCLogEntry -Message 'Error during Export:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return ''
    }
}

Export-ModuleMember -Function *-TargetResource
