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
        [System.String[]]
        $AppPresetList,

        [Parameter()]
        [System.String[]]
        $AppPresetMeetingList,

        [Parameter()]
        [System.String[]]
        $PinnedAppBarApps,

        [Parameter()]
        [System.String[]]
        $PinnedMessageBarApps,

        [Parameter()]
        [System.Boolean]
        $AllowUserPinning,

        [Parameter()]
        [System.Boolean]
        $AllowSideLoading,

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

            $instance = Get-CsTeamsAppSetupPolicy -Identity $Identity -ErrorAction SilentlyContinue
        }
        else
        {
            $instance = $Script:exportedInstance
        }

        if ($null -eq $instance)
        {
            return $nullResult
        }

        $AppPresetListValue = $instance.AppPresetList.Id
        if ($instance.AppPresetList.Count -eq 0)
        {
            $AppPresetListValue = @()
        }

        $AppPresetMeetingListValue = $instance.AppPresetMeetingList.Id
        if ($instance.AppPresetMeetingList.Count -eq 0)
        {
            $AppPresetMeetingListValue = @()
        }

        $PinnedAppBarAppsValue = $instance.PinnedAppBarApps.Id
        if ($instance.PinnedAppBarApps.Count -eq 0)
        {
            $PinnedAppBarAppsValue = @()
        }

        $PinnedMessageBarAppsValue = $instance.PinnedMessageBarApps.Id
        if ($instance.PinnedMessageBarApps.Count -eq 0)
        {
            $PinnedMessageBarAppsValue = @()
        }

        Write-Verbose -Message "Found an instance with Identity {$Identity}"
        $results = @{
            Identity              = $instance.Identity.Replace('Tag:', '')
            Description           = $instance.Description
            AppPresetList         = [Array]$AppPresetListValue
            AppPresetMeetingList  = [Array]$AppPresetMeetingListValue
            PinnedAppBarApps      = [Array]$PinnedAppBarAppsValue
            PinnedMessageBarApps  = [Array]$PinnedMessageBarAppsValue
            AllowUserPinning      = $instance.AllowUserPinning
            AllowSideLoading      = $instance.AllowSideLoading
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

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $AppPresetList,

        [Parameter()]
        [System.String[]]
        $AppPresetMeetingList,

        [Parameter()]
        [System.String[]]
        $PinnedAppBarApps,

        [Parameter()]
        [System.String[]]
        $PinnedMessageBarApps,

        [Parameter()]
        [System.Boolean]
        $AllowUserPinning,

        [Parameter()]
        [System.Boolean]
        $AllowSideLoading,

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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
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

    $currentInstance = Get-TargetResource @PSBoundParameters

    $PSBoundParameters.Remove('Ensure') | Out-Null
    $PSBoundParameters.Remove('Credential') | Out-Null
    $PSBoundParameters.Remove('ApplicationId') | Out-Null
    $PSBoundParameters.Remove('ApplicationSecret') | Out-Null
    $PSBoundParameters.Remove('TenantId') | Out-Null
    $PSBoundParameters.Remove('CertificateThumbprint') | Out-Null
    $PSBoundParameters.Remove('ManagedIdentity') | Out-Null
    $PSBoundParameters.Remove('AccessTokens') | Out-Null

    $appPresetValues = @()
    if ($null -ne $AppPresetList -and ([Array]$AppPresetList).Count -gt 0)
    {
        foreach ($appInstance in $AppPresetList)
        {
            $appPresetValues += [Microsoft.Teams.Policy.Administration.Cmdlets.Core.AppPreset]::New($appInstance)
        }
    }

    $appPresetMeetingValues = @()
    if ($null -ne $AppPresetMeetingList -and ([Array]$AppPresetMeetingList).Count -gt 0)
    {
        foreach ($appInstance in $AppPresetMeetingList)
        {
            $appPresetMeetingValues += [Microsoft.Teams.Policy.Administration.Cmdlets.Core.AppPresetMeeting]::New($appInstance)
        }
    }

    $pinnedAppBarAppsValue = @()
    if ($null -ne $PinnedAppBarApps -and ([Array]$PinnedAppBarApps).Count -gt 0)
    {
        $i = 1
        foreach ($appInstance in $PinnedAppBarApps)
        {
            $pinnedAppBarAppsValue += [Microsoft.Teams.Policy.Administration.Cmdlets.Core.PinnedApp]::New($appInstance, $i)
            $i++
        }
    }

    $pinnedMessageBarAppsValue = @()
    if ($null -ne $PinnedMessageBarApps -and ([Array]$PinnedMessageBarApps).Count -gt 0)
    {
        $i = 1
        foreach ($appInstance in $PinnedMessageBarApps)
        {
            $pinnedMessageBarAppsValue += [Microsoft.Teams.Policy.Administration.Cmdlets.Core.PinnedMessageBarApp]::New($appInstance, $i)
            $i++
        }
    }

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        $CreateParameters = ([Hashtable]$PSBoundParameters).Clone()
        $CreateParameters.Remove('Verbose') | Out-Null
        Write-Verbose -Message "Creating {$Identity} with Parameters:`r`n$(Convert-M365DscHashtableToString -Hashtable $CreateParameters)"

        $CreateParameters.AppPresetList = $appPresetValues
        $CreateParameters.AppPresetMeetingList = $appPresetMeetingValues
        $CreateParameters.PinnedAppBarApps = $pinnedAppBarAppsValue
        $CreateParameters.PinnedMessageBarApps = $pinnedMessageBarAppsValue

        New-CsTeamsAppSetupPolicy @CreateParameters | Out-Null
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        $UpdateParameters = ([Hashtable]$PSBoundParameters).Clone()
        $UpdateParameters.Remove('Verbose') | Out-Null
        Write-Verbose -Message "Updating {$Identity}"

        $UpdateParameters.AppPresetList = $appPresetValues
        $UpdateParameters.AppPresetMeetingList = $appPresetMeetingValues
        $UpdateParameters.PinnedAppBarApps = $pinnedAppBarAppsValue
        $UpdateParameters.PinnedMessageBarApps = $pinnedMessageBarAppsValue

        Set-CsTeamsAppSetupPolicy @UpdateParameters | Out-Null
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing {$Identity}"
        Remove-CsTeamsAppSetupPolicy -Identity $currentInstance.Identity
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
        [System.String[]]
        $AppPresetList,

        [Parameter()]
        [System.String[]]
        $AppPresetMeetingList,

        [Parameter()]
        [System.String[]]
        $PinnedAppBarApps,

        [Parameter()]
        [System.String[]]
        $PinnedMessageBarApps,

        [Parameter()]
        [System.Boolean]
        $AllowUserPinning,

        [Parameter()]
        [System.Boolean]
        $AllowSideLoading,

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

    Write-Verbose -Message "Testing configuration of {$Identity}"

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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftTeams' `
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
        [array]$getValue = Get-CsTeamsAppSetupPolicy -ErrorAction Stop

        $i = 1
        $dscContent = ''
        if ($getValue.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($config in $getValue)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = $config.Identity
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
            $params = @{
                Identity              = $config.Identity
                Ensure                = 'Present'
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

Export-ModuleMember -Function *-TargetResource
