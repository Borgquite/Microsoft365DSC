function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $LibraryUrl,

        [Parameter()]
        [System.String]
        $ThumbnailUrl,

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String]
        $CdnType = 'Public',

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

    Write-Verbose -Message 'Getting configuration of SPO Org Assets Library'

    try
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'PnP' `
            -InboundParameters $PSBoundParameters

        if ($ConnectionMode -eq 'Credentials')
        {
            $tenantName = Get-M365TenantName -Credential $Credential
        }
        else
        {
            $tenantName = $TenantId.Split('.')[0]
        }
        $orgLibraryUrl = "https://$tenantName.sharepoint.com/$($Script:exportedInstance.libraryurl.DecodedUrl)"

        if (-not $Script:exportedInstance -or $orgLibraryUrl -ne $LibraryUrl)
        {
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

            $orgAssets = Get-PnPOrgAssetsLibrary -ErrorAction SilentlyContinue

            $cdn = $null
            if ($CdnType -eq 'Public')
            {
                if (Get-PnPTenantCdnEnabled -CdnType $CdnType)
                {
                    $cdn = 'Public'
                }
            }

            if ($CdnType -eq 'Private')
            {
                if (Get-PnPTenantCdnEnabled -CdnType $CdnType)
                {
                    $cdn = 'Private'
                }
            }

            if ($null -eq $orgAssets)
            {
                return $nullReturn
            }

            foreach ($asset in $orgAssets)
            {
                $orgLibraryUrl = "https://$tenantName.sharepoint.com/$($asset.libraryurl.DecodedUrl)"
                if ($orgLibraryUrl -eq $LibraryUrl)
                {
                    $orgAsset = $asset
                    break
                }
            }
        }
        else
        {
            $orgAsset = $Script:exportedInstance
        }

        Write-Verbose -Message "Found existing SharePoint Org Site Assets for $LibraryUrl"
        if ($null -ne $orgAsset.ThumbnailUrl.DecodedUrl)
        {
            $orgthumbnailUrl = "https://$tenantName.sharepoint.com/$($orgAsset.LibraryUrl.decodedurl.Substring(0,$orgAsset.LibraryUrl.decodedurl.LastIndexOf('/')))/$($orgAsset.ThumbnailUrl.decodedurl)"
        }

        $result = @{
            LibraryUrl            = $orgLibraryUrl
            ThumbnailUrl          = $orgthumbnailUrl
            CdnType               = $cdn
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificatePassword   = $CertificatePassword
            CertificatePath       = $CertificatePath
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
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
        [System.String]
        $LibraryUrl,

        [Parameter()]
        [System.String]
        $ThumbnailUrl,

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String]
        $CdnType = 'Public',

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

    Write-Verbose -Message 'Setting configuration of SharePoint Org Site Assets'

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

    $currentOrgSiteAsset = Get-TargetResource @PSBoundParameters
    $currentParameters = $PSBoundParameters
    $currentParameters.Remove('Ensure') | Out-Null
    $currentParameters.Remove('Credential') | Out-Null
    $currentParameters.Remove('ApplicationId') | Out-Null
    $currentParameters.Remove('TenantId') | Out-Null
    $currentParameters.Remove('CertificatePath') | Out-Null
    $currentParameters.Remove('CertificatePassword') | Out-Null
    $CurrentParameters.Remove('CertificateThumbprint') | Out-Null
    $CurrentParameters.Remove('ManagedIdentity') | Out-Null
    $CurrentParameters.Remove('ApplicationSecret') | Out-Null
    $currentParameters.Remove('AccessTokens') | Out-Null

    $cdn = $null
    if ($CdnType -eq 'Public')
    {
        if (Get-PnPTenantCdnEnabled -CdnType $CdnType)
        {
            $cdn = 'Public'
        }
    }

    if ($CdnType -eq 'Private')
    {
        if (Get-PnPTenantCdnEnabled -CdnType $CdnType)
        {
            $cdn = 'Private'
        }
    }

    if ($null -eq $cdn)
    {
        throw "Tenant $CdnType CDN must be configured before setting site organization Library"
    }

    if ($Ensure -eq 'Present' -and $currentOrgSiteAsset.Ensure -eq 'Present')
    {
        Write-Verbose -Message 'Removing existing Org Asset Library'
        ## No set so remove / add
        Remove-PnPOrgAssetsLibrary -LibraryUrl $currentOrgSiteAsset.LibraryUrl
        ### add slight delay fails if you immediately try to add
        Write-Verbose -Message 'Waiting 30 seconds'
        Start-Sleep -Seconds 30
        Write-Verbose -Message 'Adding Org Asset Library'
        Add-PnPOrgAssetsLibrary @currentParameters
    }
    elseif ($Ensure -eq 'Present' -and $currentOrgSiteAsset.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Adding Org Asset Library $($currentParameters.LibraryUrl)"
        try
        {
            Add-PnPOrgAssetsLibrary @currentParameters -ErrorAction Stop
        }
        catch
        {
            Write-Warning -Message "Exception: $($_.Exception)"
            if ($_ -notlike '*This library is already an organization assets library.*')
            {
                throw $_
            }
        }
    }
    elseif ($Ensure -eq 'Absent' -and $currentOrgSiteAsset.Ensure -eq 'Present')
    {
        Write-Verbose -Message 'Removing existing Org Asset Library'
        Remove-PnPOrgAssetsLibrary -LibraryUrl $currentOrgSiteAsset.LibraryUrl
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
        $LibraryUrl,

        [Parameter()]
        [System.String]
        $ThumbnailUrl,

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String]
        $CdnType = 'Public',

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

    Write-Verbose -Message 'Testing configuration of SharePoint Org Site Assets'

    $CurrentValues = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message 'Starting the test to compare'
    Write-Verbose -Message "Target Values: `n $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

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
        $ConnectionMode = New-M365DSCConnection -Workload 'PnP' `
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

        [array]$orgAssets = Get-PnPOrgAssetsLibrary -ErrorAction Stop
        $i = 1
        $dscContent = ''

        if ($orgAssets.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        if ($null -ne $orgAssets)
        {
            foreach ($orgAssetLib in $orgAssets)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    [$i/$($orgAssets.Length)] $($orgAssetLib.libraryurl.DecodedUrl)" -DeferWrite
                $Params = @{
                    Credential            = $Credential
                    LibraryUrl            = "https://$tenantName.sharepoint.com/$($orgAssetLib.libraryurl.DecodedUrl)"
                    ApplicationId         = $ApplicationId
                    TenantId              = $TenantId
                    CertificatePassword   = $CertificatePassword
                    CertificatePath       = $CertificatePath
                    CertificateThumbprint = $CertificateThumbprint
                    Managedidentity       = $ManagedIdentity.IsPresent
                    ApplicationSecret     = $ApplicationSecret
                    AccessTokens          = $AccessTokens
                }

                $Script:exportedInstance = $orgAssetLib
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
