function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Yes')]
        $IsSingleInstance = 'Yes',

        [Parameter()]
        [System.Boolean]
        $AllowPSTNOnlyMeetingsByDefault,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyMigrateUserMeetings,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyReplaceAcpProvider,

        [Parameter()]
        [System.Boolean]
        $AutomaticallySendEmailsToUsers,

        [Parameter()]
        [System.Boolean]
        $EnableDialOutJoinConfirmation,

        [Parameter()]
        [System.Boolean]
        $EnableEntryExitNotifications,

        [Parameter()]
        [System.String]
        $EntryExitAnnouncementsType,

        [Parameter()]
        [System.String]
        [ValidateSet('MaskedForExternalUsers', 'MaskedForAllUsers', 'NoMasking')]
        $MaskPstnNumbersType,

        [Parameter()]
        [System.UInt32]
        $PinLength,

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

    Write-Verbose -Message 'Getting the Teams Dial In Conferencing Tenant Settings'

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

    $nullReturn = @{
        IsSingleInstance = 'Yes'
    }

    try
    {
        $instance = Get-CsOnlineDialInConferencingTenantSettings -ErrorAction SilentlyContinue

        return @{
            IsSingleInstance                 = 'Yes'
            AllowPSTNOnlyMeetingsByDefault   = $instance.AllowPSTNOnlyMeetingsByDefault
            AutomaticallyMigrateUserMeetings = $instance.AutomaticallyMigrateUserMeetings
            AutomaticallyReplaceAcpProvider  = $instance.AutomaticallyReplaceAcpProvider
            AutomaticallySendEmailsToUsers   = $instance.AutomaticallySendEmailsToUsers
            EnableDialOutJoinConfirmation    = $instance.EnableDialOutJoinConfirmation
            EnableEntryExitNotifications     = $instance.EnableEntryExitNotifications
            EntryExitAnnouncementsType       = $instance.EntryExitAnnouncementsType
            MaskPstnNumbersType              = $instance.MaskPstnNumbersType
            PinLength                        = $instance.PinLength
            Credential                       = $Credential
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
            ManagedIdentity                  = $ManagedIdentity.IsPresent
            AccessTokens                     = $AccessTokens
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
        [ValidateSet('Yes')]
        $IsSingleInstance = 'Yes',

        [Parameter()]
        [System.Boolean]
        $AllowPSTNOnlyMeetingsByDefault,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyMigrateUserMeetings,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyReplaceAcpProvider,

        [Parameter()]
        [System.Boolean]
        $AutomaticallySendEmailsToUsers,

        [Parameter()]
        [System.Boolean]
        $EnableDialOutJoinConfirmation,

        [Parameter()]
        [System.Boolean]
        $EnableEntryExitNotifications,

        [Parameter()]
        [System.String]
        $EntryExitAnnouncementsType,

        [Parameter()]
        [System.String]
        [ValidateSet('MaskedForExternalUsers', 'MaskedForAllUsers', 'NoMasking')]
        $MaskPstnNumbersType,

        [Parameter()]
        [System.UInt32]
        $PinLength,

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

    Write-Verbose -Message 'Setting Teams Dial In Conferencing Tenant Settings'

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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
        -InboundParameters $PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $SetParameters = $PSBoundParameters
    $SetParameters.Remove('Credential') | Out-Null
    $SetParameters.Remove('ApplicationId') | Out-Null
    $SetParameters.Remove('TenantId') | Out-Null
    $SetParameters.Remove('CertificateThumbprint') | Out-Null
    $SetParameters.Remove('IsSingleInstance') | Out-Null
    $SetParameters.Remove('ManagedIdentity') | Out-Null
    $SetParameters.Remove('AccessTokens') | Out-Null

    try
    {
        Set-CsOnlineDialInConferencingTenantSettings @SetParameters
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error updating data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential
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
        [ValidateSet('Yes')]
        $IsSingleInstance = 'Yes',

        [Parameter()]
        [System.Boolean]
        $AllowPSTNOnlyMeetingsByDefault,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyMigrateUserMeetings,

        [Parameter()]
        [System.Boolean]
        $AutomaticallyReplaceAcpProvider,

        [Parameter()]
        [System.Boolean]
        $AutomaticallySendEmailsToUsers,

        [Parameter()]
        [System.Boolean]
        $EnableDialOutJoinConfirmation,

        [Parameter()]
        [System.Boolean]
        $EnableEntryExitNotifications,

        [Parameter()]
        [System.String]
        $EntryExitAnnouncementsType,

        [Parameter()]
        [System.String]
        [ValidateSet('MaskedForExternalUsers', 'MaskedForAllUsers', 'NoMasking')]
        $MaskPstnNumbersType,

        [Parameter()]
        [System.UInt32]
        $PinLength,

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

    Write-Verbose -Message 'Testing configuration of Teams Dial In Conferencing Tenant Settings'

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
        $dscContent = [System.Text.StringBuilder]::new()
        $params = @{
            IsSingleInstance      = 'Yes'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }
        $Results = Get-TargetResource @Params
        if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
            $dscContent.Append($currentDSCBlock) | Out-Null
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName

            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
        }

        return $dscContent.ToString()
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
