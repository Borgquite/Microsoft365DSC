function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Properties,

        [Parameter()]
        [ValidateSet('Present')]
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

    Write-Verbose -Message "Getting SPO Profile Properties for user {$UserName}"

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

        $nullReturn = @{
            UserName = $UserName
            Ensure   = 'Absent'
        }

        $currentProperties = Get-PnPUserProfileProperty -Account $UserName -ErrorAction Stop

        if ($null -eq $currentProperties.AccountName)
        {
            return $nullReturn
        }
        $currentProperties = $currentProperties.UserProfileProperties
        $propertiesValue = @()

        foreach ($key in $currentProperties.Keys)
        {
            $convertedProperty = Get-SPOUserProfilePropertyInstance -Key $key -Value $currentProperties[$key]
            $propertiesValue += $convertedProperty
        }

        $result = @{
            UserName              = $UserName
            Properties            = $propertiesValue
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
            Ensure                = 'Present'
            AccessTokens          = $AccessTokens
        }

        Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"

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
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Properties,

        [Parameter()]
        [ValidateSet('Present')]
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

    Write-Verbose -Message "Setting Profile Properties for user {$UserName}"

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

    $currentProperties = Get-TargetResource @PSBoundParameters

    foreach ($property in $Properties)
    {
        if ($currentProperties.Properties[$property.Key] -ne $property.Value)
        {
            Write-Verbose "Setting Profile Property {$($property.Key)} as {$($property.Value)}"
            try
            {
                Set-PnPUserProfileProperty -Account $UserName -PropertyName $property.Key -Value $property.Value -ErrorAction Stop
            }
            catch
            {
                Write-Warning "Cannot update property {$($property.Key)}. This value of that key cannot be modified."
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Properties,

        [Parameter()]
        [ValidateSet('Present')]
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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message 'Testing configuration for SPO Sharing settings'

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $TestResult = Test-M365DSCParameterState -DesiredValues $PSBoundParameters `
        -Source $($MyInvocation.MyCommand.Source) `
        -CurrentValues $CurrentValues

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

        # Get all instances;
        $instances = Get-PnPUser | Where-Object -FilterScript { $_.PrincipalType -eq 'User' -and '' -ne $_.Email }
        $dscContent = ''
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        $i = 1
        foreach ($instance in $Instances)
        {
            Write-M365DSCHost -Message "    |---[$i/$($Instances.Count)] $($instance.Email)" -DeferWrite
            $Params = @{
                UserName              = $instance.Email
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                Credential            = $Credential
                AccessTokens          = $AccessTokens
            }

            $Results = Get-TargetResource @Params
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                if ($Results.Properties)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    if ($null -ne $Results.Properties)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'Properties'
                                CimInstanceName = 'MSFT_SPOUserProfilePropertyInstance'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.Properties `
                            -CIMInstanceName 'MSFT_SPOUserProfilePropertyInstance' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.Properties = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Properties') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $PSScriptRoot `
                        -Results $Results `
                        -Credential $Credential `
                        -NoEscape @('Properties')
                    $dscContent += $currentDSCBlock
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                }

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            $i++
        }

        $organization = ''
        $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
        $organization = Get-M365DSCOrganization -Credential $Credential -TenantId $Tenantid
        if ($organization.IndexOf('.') -gt 0)
        {
            $principal = $organization.Split('.')[0]
        }
        if ($dscContent.ToLower().Contains($organization.ToLower()) -or `
                $dscContent.ToLower().Contains($principal.ToLower()))
        {
            $dscContent = $dscContent -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
            $dscContent = $dscContent -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
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
