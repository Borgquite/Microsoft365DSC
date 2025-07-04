function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Boolean]
        $AllowManagedUpdates,

        [Parameter()]
        [System.Boolean]
        $AllowPreview,

        [Parameter()]
        [System.String]
        [ValidateSet('Disabled', 'Enabled', 'Forced', 'FollowOfficePreview')]
        $AllowPublicPreview,

        [Parameter()]
        [System.UInt32]
        [ValidateRange(0, 6)]
        $UpdateDayOfWeek,

        [Parameter()]
        [System.String]
        $UpdateTime,

        [Parameter()]
        [System.String]
        $UpdateTimeOfDay,

        [Parameter()]
        [ValidateSet('UserChoice', 'MicrosoftChoice', 'AdminDisabled', 'NewTeamsAsDefault', 'NewTeamsOnly')]
        [System.String]
        $UseNewTeamsClient,

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

            Write-Verbose -Message 'Checking the Teams Update Management Policies'

            $nullReturn = $PSBoundParameters
            $nullReturn.Ensure = 'Absent'

            $policy = Get-CsTeamsUpdateManagementPolicy -Identity $Identity `
                -ErrorAction SilentlyContinue
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        if ($null -eq $policy)
        {
            Write-Verbose "No Teams Update Management Policy with Identity {$Identity} was found"
            return $nullReturn
        }

        Write-Verbose -Message "Found Teams Update Management Policy with Identity {$Identity}"
        $results = @{
            Identity              = $policy.Identity
            Description           = $policy.Description
            AllowManagedUpdates   = $policy.AllowManagedUpdates
            AllowPreview          = $policy.AllowPreview
            AllowPublicPreview    = $policy.AllowPublicPreview
            UpdateDayOfWeek       = $policy.UpdateDayOfWeek
            UpdateTime            = $policy.UpdateTime
            UseNewTeamsClient     = $policy.UseNewTeamsClient
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }
        if (-not [System.String]::IsNullOrEmpty($policy.UpdateTimeOfDay))
        {
            $updateTimeOfDayValue = $policy.UpdateTimeOfDay.ToShortTimeString()
            $results.Add('UpdateTimeOfDay', $updateTimeOfDayValue)
        }
        return $results
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

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Boolean]
        $AllowManagedUpdates,

        [Parameter()]
        [System.Boolean]
        $AllowPreview,

        [Parameter()]
        [System.String]
        [ValidateSet('Disabled', 'Enabled', 'Forced', 'FollowOfficePreview')]
        $AllowPublicPreview,

        [Parameter()]
        [System.UInt32]
        [ValidateRange(0, 6)]
        $UpdateDayOfWeek,

        [Parameter()]
        [System.String]
        $UpdateTime,

        [Parameter()]
        [System.String]
        $UpdateTimeOfDay,

        [Parameter()]
        [ValidateSet('UserChoice', 'MicrosoftChoice', 'AdminDisabled', 'NewTeamsAsDefault', 'NewTeamsOnly')]
        [System.String]
        $UseNewTeamsClient,

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
    Write-Verbose -Message "Updating Teams Update Management Policy {$Identity}"

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
        -InboundParameters $PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $PSBoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    if ($CurrentValues.Ensure -eq 'Absent' -and $Ensure -eq 'Present')
    {
        Write-Verbose "Creating new Teams Update Management Policy {$Identity}"

        New-CsTeamsUpdateManagementPolicy @PSBoundParameters | Out-Null
    }
    elseif ($CurrentValues.Ensure -eq 'Present' -and $Ensure -eq 'Present')
    {
        Write-Verbose "Updating existing Teams Update Management Policy {$Identity}"

        Set-CsTeamsUpdateManagementPolicy @PSBoundParameters | Out-Null
    }
    elseif ($CurrentValues.Ensure -eq 'Present' -and $Ensure -eq 'Absent')
    {
        Write-Verbose "Removing existing Teams Update Management Policy {$Identity}"

        Remove-CsTeamsUpdateManagementPolicy -Identity $Identity | Out-Null
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

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.Boolean]
        $AllowManagedUpdates,

        [Parameter()]
        [System.Boolean]
        $AllowPreview,

        [Parameter()]
        [System.String]
        [ValidateSet('Disabled', 'Enabled', 'Forced', 'FollowOfficePreview')]
        $AllowPublicPreview,

        [Parameter()]
        [System.UInt32]
        [ValidateRange(0, 6)]
        $UpdateDayOfWeek,

        [Parameter()]
        [System.String]
        $UpdateTime,

        [Parameter()]
        [System.String]
        $UpdateTimeOfDay,

        [Parameter()]
        [ValidateSet('UserChoice', 'MicrosoftChoice', 'AdminDisabled', 'NewTeamsAsDefault', 'NewTeamsOnly')]
        [System.String]
        $UseNewTeamsClient,

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
    Write-Verbose -Message "Testing configuration of Team Update Management Policy {$Identity}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testResult = $true

    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck

    if ($PSBoundParameters.ContainsKey('UpdateTimeOfDay'))
    {
        Write-Verbose -Message "Converting UpdateTimeOfDay ($UpdateTimeOfDay) to the current culture format"
        $dtUpdateTimeOfDay = [datetime]::Parse($PSBoundParameters.UpdateTimeOfDay)
        $PSBoundParameters.UpdateTimeOfDay = $dtUpdateTimeOfDay.ToShortTimeString()
        Write-Verbose -Message "  Converted value $($PSBoundParameters.UpdateTimeOfDay))"
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    if ($testResult)
    {
        $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
    }

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
        [array]$policies = Get-CsTeamsUpdateManagementPolicy -ErrorAction Stop
        $i = 1
        $dscContent = ''
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        foreach ($policy in $policies)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity.Replace('Tag:', ''))" -DeferWrite
            $params = @{
                Identity              = $policy.Identity.Replace('Tag:', '')
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
            $result = Get-TargetResource @params
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $result `
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

Export-ModuleMember -Function *-TargetResource
