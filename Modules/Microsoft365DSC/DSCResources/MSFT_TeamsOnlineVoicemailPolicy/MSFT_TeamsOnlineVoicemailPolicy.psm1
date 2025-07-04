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
        [System.Boolean]
        $EnableEditingCallAnswerRulesSetting,

        [Parameter()]
        [System.Boolean]
        $EnableTranscription,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionProfanityMasking,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionTranslation,

        [Parameter()]
        [System.String]
        $MaximumRecordingLength,

        [Parameter()]
        [System.String]
        $PrimarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $SecondarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $ShareData,

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

    Write-Verbose -Message "Getting the Teams Online Voicemail Policy $($Identity)"

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

            $policy = Get-CsOnlineVoicemailPolicy -Identity $Identity `
                -ErrorAction 'SilentlyContinue'
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        if ($null -eq $policy)
        {
            Write-Verbose -Message "Could not find Teams Online Voicemail Policy ${$Identity}"
            return $nullReturn
        }

        Write-Verbose -Message "Found Teams Online Voicemail Policy {$Identity}"
        return @{
            Identity                            = $policy.Identity.Replace('Tag:', '')
            EnableEditingCallAnswerRulesSetting = $policy.EnableEditingCallAnswerRulesSetting
            EnableTranscription                 = $policy.EnableTranscription
            EnableTranscriptionProfanityMasking = $policy.EnableTranscriptionProfanityMasking
            EnableTranscriptionTranslation      = $policy.EnableTranscriptionTranslation
            MaximumRecordingLength              = $policy.MaximumRecordingLength
            PrimarySystemPromptLanguage         = $policy.PrimarySystemPromptLanguage
            SecondarySystemPromptLanguage       = $policy.SecondarySystemPromptLanguage
            ShareData                           = $policy.ShareData
            Ensure                              = 'Present'
            Credential                          = $Credential
            ApplicationId                       = $ApplicationId
            TenantId                            = $TenantId
            CertificateThumbprint               = $CertificateThumbprint
            ManagedIdentity                     = $ManagedIdentity.IsPresent
            AccessTokens                        = $AccessTokens
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

        [Parameter()]
        [System.Boolean]
        $EnableEditingCallAnswerRulesSetting,

        [Parameter()]
        [System.Boolean]
        $EnableTranscription,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionProfanityMasking,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionTranslation,

        [Parameter()]
        [System.String]
        $MaximumRecordingLength,

        [Parameter()]
        [System.String]
        $PrimarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $SecondarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $ShareData,

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

    Write-Verbose -Message 'Setting Teams Online Voicemail Policy'

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

    # Convert the MaximumRecordingLength back to a timespan object.
    $timespan = [TimeSpan]$MaximumRecordingLength
    $SetParameters.MaximumRecordingLength = $timespan

    if ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating a new Teams Online Voicemail Policy {$Identity}"

        New-CsOnlineVoicemailPolicy @SetParameters
    }
    elseif ($Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating settings for Teams Online Voicemail Policy {$Identity}"

        Set-CsOnlineVoicemailPolicy @SetParameters
    }
    elseif ($Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing existing Teams Online Voicemail Policy {$Identity}"
        Remove-CsOnlineVoicemailPolicy -Identity $Identity
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
        [System.Boolean]
        $EnableEditingCallAnswerRulesSetting,

        [Parameter()]
        [System.Boolean]
        $EnableTranscription,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionProfanityMasking,

        [Parameter()]
        [System.Boolean]
        $EnableTranscriptionTranslation,

        [Parameter()]
        [System.String]
        $MaximumRecordingLength,

        [Parameter()]
        [System.String]
        $PrimarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $SecondarySystemPromptLanguage,

        [Parameter()]
        [System.String]
        $ShareData,

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

    Write-Verbose -Message "Testing configuration of Team Online Voicemail Policy {$Identity}"

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
        $i = 1
        [array]$policies = Get-CsOnlineVoicemailPolicy -ErrorAction Stop
        $dscContent = ''
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        foreach ($policy in $policies)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity)" -DeferWrite
            $params = @{
                Identity              = $policy.Identity
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
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
