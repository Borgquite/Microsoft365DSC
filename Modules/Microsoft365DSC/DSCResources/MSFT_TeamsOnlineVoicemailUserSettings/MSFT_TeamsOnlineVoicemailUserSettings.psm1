function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Identity,

        [Parameter()]
        [System.String]
        [ValidateSet('DeclineCall', 'PromptOnly', 'PromptOnlyWithTransfer', 'RegularVoicemail', 'VoicemailWithTransferOption')]
        $CallAnswerRule,

        [Parameter()]
        [System.String]
        $DefaultGreetingPromptOverwrite,

        [Parameter()]
        [System.String]
        $DefaultOofGreetingPromptOverwrite,

        [Parameter()]
        [System.Boolean]
        $OofGreetingEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowAutomaticRepliesEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowCalendarEnabled,

        [Parameter()]
        [System.String]
        $PromptLanguage,

        [Parameter()]
        [System.Boolean]
        $ShareData,

        [Parameter()]
        [System.String]
        $TransferTarget,

        [Parameter()]
        [System.Boolean]
        $VoicemailEnabled,

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

    Write-Verbose -Message "Getting the Teams Online Voicemail User Settings $($Identity)"

    try
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

        $instance = Get-CsOnlineVoicemailUserSettings -Identity $Identity -ErrorAction 'SilentlyContinue'

        if ($null -eq $instance)
        {
            Write-Verbose -Message "Could not find Teams Online Voicemail User Settings for ${$Identity}"
            return $nullReturn
        }

        Write-Verbose -Message "Found Teams Online Voicemail User Settings for {$Identity}"
        return @{
            Identity                                 = $Identity
            CallAnswerRule                           = $instance.CallAnswerRule
            DefaultGreetingPromptOverwrite           = $instance.DefaultGreetingPromptOverwrite
            DefaultOofGreetingPromptOverwrite        = $instance.DefaultOofGreetingPromptOverwrite
            OofGreetingEnabled                       = $instance.OofGreetingEnabled
            OofGreetingFollowAutomaticRepliesEnabled = $instance.OofGreetingFollowAutomaticRepliesEnabled
            OofGreetingFollowCalendarEnabled         = $instance.OofGreetingFollowCalendarEnabled
            PromptLanguage                           = $instance.PromptLanguage
            ShareData                                = $instance.ShareData
            TransferTarget                           = $instance.TransferTarget
            VoicemailEnabled                         = $instance.VoicemailEnabled
            Ensure                                   = 'Present'
            Credential                               = $Credential
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
            ManagedIdentity                          = $ManagedIdentity.IsPresent
            AccessTokens                             = $AccessTokens
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
        [string]
        $Identity,

        [Parameter()]
        [System.String]
        [ValidateSet('DeclineCall', 'PromptOnly', 'PromptOnlyWithTransfer', 'RegularVoicemail', 'VoicemailWithTransferOption')]
        $CallAnswerRule,

        [Parameter()]
        [System.String]
        $DefaultGreetingPromptOverwrite,

        [Parameter()]
        [System.String]
        $DefaultOofGreetingPromptOverwrite,

        [Parameter()]
        [System.Boolean]
        $OofGreetingEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowAutomaticRepliesEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowCalendarEnabled,

        [Parameter()]
        [System.String]
        $PromptLanguage,

        [Parameter()]
        [System.Boolean]
        $ShareData,

        [Parameter()]
        [System.String]
        $TransferTarget,

        [Parameter()]
        [System.Boolean]
        $VoicemailEnabled,

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

    Write-Verbose -Message 'Setting Teams Online Voicemail User Settings'

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
    $SetParameters.Remove('Ensure') | Out-Null
    $SetParameters.Remove('Credential') | Out-Null
    $SetParameters.Remove('ApplicationId') | Out-Null
    $SetParameters.Remove('TenantId') | Out-Null
    $SetParameters.Remove('CertificateThumbprint') | Out-Null
    $SetParameters.Remove('ManagedIdentity') | Out-Null
    $SetParameters.Remove('AccessTokens') | Out-Null

    try
    {
        Set-CsOnlineVoicemailUserSettings @SetParameters
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
        [string]
        $Identity,

        [Parameter()]
        [System.String]
        [ValidateSet('DeclineCall', 'PromptOnly', 'PromptOnlyWithTransfer', 'RegularVoicemail', 'VoicemailWithTransferOption')]
        $CallAnswerRule,

        [Parameter()]
        [System.String]
        $DefaultGreetingPromptOverwrite,

        [Parameter()]
        [System.String]
        $DefaultOofGreetingPromptOverwrite,

        [Parameter()]
        [System.Boolean]
        $OofGreetingEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowAutomaticRepliesEnabled,

        [Parameter()]
        [System.Boolean]
        $OofGreetingFollowCalendarEnabled,

        [Parameter()]
        [System.String]
        $PromptLanguage,

        [Parameter()]
        [System.Boolean]
        $ShareData,

        [Parameter()]
        [System.String]
        $TransferTarget,

        [Parameter()]
        [System.Boolean]
        $VoicemailEnabled,

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

    Write-Verbose -Message "Testing configuration of Team Online Voicemail User Settings {$Identity}"

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
        $allUsers = Get-CsOnlineUser -Properties 'UserPrincipalName'
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        $dscContent = [System.Text.StringBuilder]::New()
        foreach ($user in $allUsers)
        {
            Write-M365DSCHost -Message "    |---[$i/$($allUsers.Length)] $($user.UserPrincipalName)" -DeferWrite
            $params = @{
                Identity              = $user.UserPrincipalName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity
                AccessTokens          = $AccessTokens
            }
            $Results = Get-TargetResource @Params
            if ($Results.Ensure -eq 'Present')
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
            }
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            $i++
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
