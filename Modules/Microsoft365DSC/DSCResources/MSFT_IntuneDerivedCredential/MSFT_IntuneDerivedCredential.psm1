function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (

        #region resource params

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $HelpUrl,

        [Parameter()]
        [ValidateSet('intercede', 'entrustData', 'purebred')]
        [System.String]
        $Issuer,

        [Parameter()]
        [ValidateSet('none', 'email', 'companyPortal', 'companyPortal,email')]
        [System.String]
        $NotificationType = 'none',

        [Parameter()]
        [System.Int32]
        $RenewalThresholdPercentage,

        #endregion resource params

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
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens

    )

    Write-Verbose -Message "Getting configuration of the Intune Derived Credential with Id {$Id} and DisplayName {$DisplayName}."

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            New-M365DSCConnection -Workload 'MicrosoftGraph' `
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

            $instance = $null
            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $instance = Get-MgBetaDeviceManagementDerivedCredential -DeviceManagementDerivedCredentialSettingsId $Id -ErrorAction SilentlyContinue
            }

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find Derived Credential by Id {$Id}."

                if (-not [string]::IsNullOrEmpty($DisplayName))
                {
                    $instance = Get-MgBetaDeviceManagementDerivedCredential `
                        -All `
                        -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue

                    if ($null -eq $instance)
                    {
                        Write-Verbose -Message "Could not find Derived Credential by DisplayName {$DisplayName}."
                        return $nullResult
                    }
                }
            }
        }
        else
        {
            $instance = $Script:exportedInstance
        }

        $results = @{
            Ensure                     = 'Present'
            Id                         = $instance.Id
            DisplayName                = $instance.DisplayName
            HelpUrl                    = $instance.HelpUrl
            Issuer                     = $instance.Issuer.ToString()
            NotificationType           = $instance.NotificationType.ToString()
            RenewalThresholdPercentage = $instance.RenewalThresholdPercentage
            Credential                 = $Credential
            ApplicationId              = $ApplicationId
            TenantId                   = $TenantId
            CertificateThumbprint      = $CertificateThumbprint
            ApplicationSecret          = $ApplicationSecret
            ManagedIdentity            = $ManagedIdentity.IsPresent
            AccessTokens               = $AccessTokens
        }

        return [System.Collections.Hashtable] $results
    }
    catch
    {
        Write-Verbose -Message $_
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
    param (

        #region resource params

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $HelpUrl,

        [Parameter()]
        [ValidateSet('intercede', 'entrustData', 'purebred')]
        [System.String]
        $Issuer,

        [Parameter()]
        [System.Int32]
        $RenewalThresholdPercentage,

        #endregion resource params

        [Parameter()]
        [ValidateSet('none', 'email', 'companyPortal', 'companyPortal,email')]
        [System.String]
        $NotificationType = 'none',

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

    $currentInstance = Get-TargetResource @PSBoundParameters

    $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters
    $setParameters.Remove('Id') | Out-Null

    # CREATE
    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Derived Credential with DisplayName {$DisplayName}"

        New-MgBetaDeviceManagementDerivedCredential @SetParameters
    }
    # UPDATE is not supported API, it always creates a new Derived Credential instance
    # REMOVE
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing the Intune Derived Credential with DisplayName {$DisplayName}"

        Remove-MgBetaDeviceManagementDerivedCredential -DeviceManagementDerivedCredentialSettingsId $currentInstance.Id -Confirm:$false
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (

        #region resource params

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $HelpUrl,

        [Parameter()]
        [ValidateSet('intercede', 'entrustData', 'purebred')]
        [System.String]
        $Issuer,

        [Parameter()]
        [ValidateSet('none', 'email', 'companyPortal', 'companyPortal,email')]
        [System.String]
        $NotificationType = 'none',

        [Parameter()]
        [System.Int32]
        $RenewalThresholdPercentage,

        #endregion resource params

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
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testResult = $true

    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck
    $ValuesToCheck.Remove('Id') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    if ($testResult)
    {
        $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
    }

    Write-Verbose -Message "Test-TargetResource returned $testResult"

    return $testResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param (

        #region resource params

        [Parameter()]
        [System.String]
        $Id,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $HelpUrl,

        [Parameter()]
        [ValidateSet('intercede', 'entrustData', 'purebred')]
        [System.String]
        $Issuer,

        [Parameter()]
        [ValidateSet('none', 'email', 'companyPortal', 'companyPortal,email')]
        [System.String]
        $NotificationType = 'none',

        [Parameter()]
        [System.Int32]
        $RenewalThresholdPercentage,

        #endregion resource params

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
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
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
        $Script:ExportMode = $true
        [array] $getValue = Get-MgBetaDeviceManagementDerivedCredential -ErrorAction Stop

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
            $displayedKey = $config.Id
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite

            $params = @{
                Ensure                     = 'Present'
                Id                         = $config.Id
                DisplayName                = $config.DisplayName
                HelpUrl                    = $config.HelpUrl
                Issuer                     = $config.Issuer.ToString()
                NotificationType           = $config.NotificationType.ToString()
                RenewalThresholdPercentage = $config.RenewalThresholdPercentage
                Credential                 = $Credential
                AccessTokens               = $AccessTokens
                ApplicationId              = $ApplicationId
                TenantId                   = $TenantId
                ApplicationSecret          = $ApplicationSecret
                CertificateThumbprint      = $CertificateThumbprint
                ManagedIdentity            = $ManagedIdentity.IsPresent
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
