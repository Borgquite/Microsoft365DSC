function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.Boolean]
        $IsInverted,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Palette,

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
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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

    Write-Verbose -Message "Getting configuration for SPO Theme $Name"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Name -ne $Name)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'PNP' `
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

            Write-Verbose -Message "Getting theme $Name"
            $theme = Get-PnPTenantTheme -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.Name -eq $Name }
        }
        else
        {
            $theme = $Script:exportedInstance
        }

        if ($null -eq $theme)
        {
            Write-Verbose -Message "The specified theme doesn't exist."
            return $nullReturn
        }
        $convertedPalette = Convert-ExistingThemePaletteToHashTable -Palette ([System.Collections.Hashtable]$theme.Palette)

        return @{
            Name                  = $theme.Name
            IsInverted            = $theme.IsInverted
            Palette               = $convertedPalette
            Credential            = $Credential
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificatePassword   = $CertificatePassword
            CertificatePath       = $CertificatePath
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
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
        $Name,

        [Parameter()]
        [System.Boolean]
        $IsInverted,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Palette,

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
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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

    Write-Verbose -Message "Setting configuration for SPO Theme $Name"

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

    $ConnectionMode = New-M365DSCConnection -Workload 'PNP' `
        -InboundParameters $PSBoundParameters

    $CurrentPalette = Get-TargetResource @PSBoundParameters
    if ($Ensure -eq 'Present')
    {
        Write-Verbose 'Converting Received Palette Values into Hashtable'
        $HashPalette = Convert-NewThemePaletteToHashTable -Palette $Palette
        $AddParameters = @{
            Identity   = $Name
            IsInverted = $IsInverted
            Palette    = $HashPalette
        }

        try
        {
            $existingTheme = Get-PnPTenantTheme -Name $Name -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Verbose -Message "Theme $($Name) does not yet exist."
        }

        if ($null -eq $existingTheme)
        {
            Write-Verbose -Message "Theme {$Name} doesn't already exist. Creating it."
            Add-PnPTenantTheme @AddParameters
        }
        else
        {
            Write-Verbose -Message "Theme {$Name} already exists. Updating it"
            Add-PnPTenantTheme @AddParameters -Overwrite
        }
    }
    elseif ($Ensure -eq 'Absent' -and $CurrentPalette.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing theme $($Name)"
        try
        {
            Remove-PnPTenantTheme -Identity $Name
        }
        catch
        {
            $Message = "The SPOTheme $($Name) does not exist and for that cannot be removed."
            New-M365DSCLogEntry -Message $Message `
                -Exception $_ `
                -Source $MyInvocation.MyCommand.ModuleName
            Write-Error $Message
        }
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
        $Name,

        [Parameter()]
        [System.Boolean]
        $IsInverted,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Palette,

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
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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

    Write-Verbose -Message "Testing configuration for SPO Theme $Name"
    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('Palette') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    if ($TestResult)
    {
        $TestResult = Compare-SPOTheme -existingThemePalette $currentValues.Palette -configThemePalette $Palette
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
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

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
        $ConnectionMode = New-M365DSCConnection -Workload 'PNP' `
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

        [array]$themes = Get-PnPTenantTheme -ErrorAction Stop
        $dscContent = ''
        $i = 1

        if ($themes.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($theme in $themes)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($themes.Length)] $($theme.Name)" -DeferWrite
            $Params = @{
                Name                  = $theme.Name
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificatePassword   = $CertificatePassword
                CertificatePath       = $CertificatePath
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                Credential            = $Credential
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $theme
            $Results = Get-TargetResource @Params
            if ($null -ne $Results.Palette)
            {
                $formatted = $Results.Palette.GetEnumerator() | ForEach-Object {
                    [ordered]@{
                        Property = $_.Key
                        Value    = $_.Value
                    }
                }
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $formatted `
                    -CIMInstanceName 'MSFT_SPOThemePaletteProperty' `
                    -IsArray

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.Palette = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Palette') | Out-Null
                }
            }
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Palette')
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

function Convert-ExistingThemePaletteToHashTable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Palette
    )
    $themeHash = @{ }
    foreach ($entry in $Palette.GetEnumerator())
    {
        $themeHash[$entry.Key] = $entry.Value
    }
    return $themeHash
}

function Convert-NewThemePaletteToHashTable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Palette
    )

    $results = @{ }
    foreach ($entry in $Palette)
    {
        $results.Add($entry.Property, $entry.Value)
    }
    return $results
}

function Compare-SPOTheme
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $existingThemePalette,
        [Parameter(Mandatory = $true)]
        [System.Object]
        $configThemePalette
    )

    $existingThemePalette = $existingThemePalette.GetEnumerator() | Sort-Object -Property Name
    $configThemePalette = $configThemePalette.GetEnumerator() | Sort-Object -Property Name

    $existingThemePaletteCount = 0
    $configThemePaletteCount = 0

    foreach ($val in $existingThemePalette.Value)
    {
        if ($configThemePalette.Value.Contains($val))
        {
            $configThemePaletteCount++
        }
    }

    foreach ($val in $configThemePalette.Value)
    {
        if ($existingThemePalette.value.Contains($val))
        {
            $existingThemePaletteCount++
        }
    }

    if (($existingThemePalette.Count -eq $configThemePaletteCount) -and ($configThemePalette.Count -eq $existingThemePaletteCount))
    {
        return 'Themes are identical'
    }
    else
    {
        return 'Themes are not identical'
    }
}

Export-ModuleMember -Function *-TargetResource
