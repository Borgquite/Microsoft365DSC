function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $PartnerTenantId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $InboundTrust,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AutomaticUserConsentSettings,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
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

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.PartnerTenantId -ne $PartnerTenantId)
        {
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

            $nullResult = $PSBoundParameters
            $nullResult.Ensure = 'Absent'

            $getValue = Get-MgBetaPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $PartnerTenantId `
                -ErrorAction SilentlyContinue

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Cross Tenant Access Configuration Partner with TenantId {$PartnerTenantId}"
                return $nullResult
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }

        $B2BCollaborationInboundValue = $null
        if ($null -ne $getValue.B2BCollaborationInbound -and (Test-M365DSCB2BIsDefault -B2BSetting $getValue.B2BCollaborationInbound) -eq $false)
        {
            $B2BCollaborationInboundValue = $getValue.B2BCollaborationInbound
        }
        if ($null -ne $getValue.B2BCollaborationOutbound -and (Test-M365DSCB2BIsDefault -B2BSetting $getValue.B2BCollaborationOutbound) -eq $false)
        {
            $B2BCollaborationOutboundValue = $getValue.B2BCollaborationOutbound
        }
        if ($null -ne $getValue.B2BDirectConnectInbound -and (Test-M365DSCB2BIsDefault -B2BSetting $getValue.B2BDirectConnectInbound) -eq $false)
        {
            $B2BDirectConnectInboundValue = $getValue.B2BDirectConnectInbound
        }
        if ($null -ne $getValue.B2BDirectConnectOutbound -and (Test-M365DSCB2BIsDefault -B2BSetting $getValue.B2BDirectConnectOutbound) -eq $false)
        {
            $B2BDirectConnectOutboundValue = $getValue.B2BDirectConnectOutbound
        }
        if ($null -ne $getValue.AutomaticUserConsentSettings)
        {
            $AutomaticUserConsentSettingsValue = $getValue.AutomaticUserConsentSettings
        }
        if ($null -ne $getValue.InboundTrust)
        {
            $InboundTrustValue = $getValue.InboundTrust
        }
        $results = @{
            PartnerTenantId              = $getValue.TenantId
            B2BCollaborationInbound      = $B2BCollaborationInboundValue
            B2BCollaborationOutbound     = $B2BCollaborationOutboundValue
            B2BDirectConnectInbound      = $B2BDirectConnectInboundValue
            B2BDirectConnectOutbound     = $B2BDirectConnectOutboundValue
            AutomaticUserConsentSettings = $AutomaticUserConsentSettingsValue
            InboundTrust                 = $InboundTrustValue
            Ensure                       = 'Present'
            Credential                   = $Credential
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            ApplicationSecret            = $ApplicationSecret
            CertificateThumbprint        = $CertificateThumbprint
            ManagedIdentity              = $ManagedIdentity.IsPresent
            AccessTokens                 = $AccessTokens
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
        $PartnerTenantId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AutomaticUserConsentSettings,
        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $InboundTrust,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
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

    $OperationParams = ([Hashtable]$PSBoundParameters).Clone()
    $OperationParams.Remove('Credential') | Out-Null
    $OperationParams.Remove('ManagedIdentity') | Out-Null
    $OperationParams.Remove('ApplicationId') | Out-Null
    $OperationParams.Remove('TenantId') | Out-Null
    $OperationParams.Remove('CertificateThumbprint') | Out-Null
    $OperationParams.Remove('ApplicationSecret') | Out-Null
    $OperationParams.Remove('Ensure') | Out-Null
    $OperationParams.Remove('AccessTokens') | Out-Null

    if ($null -ne $OperationParams.B2BCollaborationInbound)
    {
        $OperationParams.B2BCollaborationInbound = (Get-M365DSCAADCrossTenantAccessPolicyB2BSetting -Setting $OperationParams.B2BCollaborationInbound)
        $OperationParams.B2BCollaborationInbound = (Update-M365DSCSettingUserIdFromUPN -Setting $OperationParams.B2BCollaborationInbound)
    }
    if ($null -ne $OperationParams.B2BCollaborationOutbound)
    {
        $OperationParams.B2BCollaborationOutbound = (Get-M365DSCAADCrossTenantAccessPolicyB2BSetting -Setting $OperationParams.B2BCollaborationOutbound)
        $OperationParams.B2BCollaborationOutbound = (Update-M365DSCSettingUserIdFromUPN -Setting $OperationParams.B2BCollaborationOutbound)
    }
    if ($null -ne $OperationParams.B2BDirectConnectInbound)
    {
        $OperationParams.B2BDirectConnectInbound = (Get-M365DSCAADCrossTenantAccessPolicyB2BSetting -Setting $OperationParams.B2BDirectConnectInbound)
        $OperationParams.B2BDirectConnectInbound = (Update-M365DSCSettingUserIdFromUPN -Setting $OperationParams.B2BDirectConnectInbound)
    }
    if ($null -ne $OperationParams.B2BDirectConnectOutbound)
    {
        $OperationParams.B2BDirectConnectOutbound = (Get-M365DSCAADCrossTenantAccessPolicyB2BSetting -Setting $OperationParams.B2BDirectConnectOutbound)
        $OperationParams.B2BDirectConnectOutbound = (Update-M365DSCSettingUserIdFromUPN -Setting $OperationParams.B2BDirectConnectOutbound)
    }
    if ($null -ne $OperationParams.AutomaticUserConsentSettings)
    {
        $OperationParams.AutomaticUserConsentSettings = (Get-M365DSCAADCrossTenantAccessPolicyAutomaticUserConsentSettings -Setting $OperationParams.AutomaticUserConsentSettings)
    }
    if ($null -ne $OperationParams.InboundTrust)
    {
        $OperationParams.InboundTrust = (Get-M365DSCAADCrossTenantAccessPolicyInboundTrust -Setting $OperationParams.InboundTrust)
    }

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Cross Tenant Access Policy Configuration Partner entry for TenantId {$PartnerTenantId}"
        Write-Verbose -Message (Convert-M365DscHashtableToString -Hashtable $OperationParams)
        $OperationParams.Add('TenantId', $PartnerTenantId)
        $OperationParams.Remove('PartnerTenantId') | Out-Null
        New-MgBetaPolicyCrossTenantAccessPolicyPartner @OperationParams
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating Cross Tenant Access Policy Configuration Partner entry with TenantId {$PartnerTenantId}"
        $OperationParams.Add('-CrossTenantAccessPolicyConfigurationPartnerTenantId', $PartnerTenantId)
        $OperationParams.Remove('PartnerTenantId') | Out-Null
        Update-MgBetaPolicyCrossTenantAccessPolicyPartner @OperationParams
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Cross Tenant Access Policy Configuration Partner entry with TenantId {$PartnerTenantId}"
        Remove-MgBetaPolicyCrossTenantAccessPolicyPartner -CrossTenantAccessPolicyConfigurationPartnerTenantId $PartnerTenantId
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
        $PartnerTenantId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BCollaborationOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectInbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $B2BDirectConnectOutbound,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $InboundTrust,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AutomaticUserConsentSettings,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
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

    Write-Verbose -Message "Testing configuration of the Azure AD Cross Tenant Access Policy Configuration Partner with Tenant Id [$PartnerTenantId]"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $testResult = $true
    $testTargetResource = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($source.getType().Name -like '*CimInstance*')
        {
            $source = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $source

            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-Not $testResult)
            {
                Write-Verbose -Message "Difference found for $key"
                $testTargetResource = $false
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null

        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"
    $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    if (-not $TestResult)
    {
        $testTargetResource = $false
    }
    Write-Verbose -Message "Test-TargetResource returned $testTargetResource"
    return $testTargetResource
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
        [array] $getValue = Get-MgBetaPolicyCrossTenantAccessPolicyPartner -ErrorAction Stop

        $i = 1
        $dscContent = ''
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        foreach ($entry in $getValue)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($entry.TenantId)" -DeferWrite
            $Params = @{
                PartnerTenantId       = $entry.TenantId
                ApplicationSecret     = $ApplicationSecret
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                Credential            = $Credential
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $entry
            $Results = Get-TargetResource @Params

            if ($null -ne $Results.B2BCollaborationInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BCollaborationInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BCollaborationInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BCollaborationInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BCollaborationInbound') | Out-Null
                }
            }

            if ($null -ne $Results.AutomaticUserConsentSettings)
            {
                $complexMapping = @(
                    @{
                        Name            = 'AutomaticUserConsentSettings'
                        CimInstanceName = 'AADCrossTenantAccessPolicyAutomaticUserConsentSettings'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.AutomaticUserConsentSettings `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyAutomaticUserConsentSettings' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.AutomaticUserConsentSettings = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AutomaticUserConsentSettings') | Out-Null
                }
            }

            if ($null -ne $Results.B2BCollaborationOutbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BCollaborationOutbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BCollaborationOutbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BCollaborationOutbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BCollaborationOutbound') | Out-Null
                }
            }

            if ($null -ne $Results.B2BDirectConnectInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BDirectConnectInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BDirectConnectInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BDirectConnectInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BDirectConnectInbound') | Out-Null
                }
            }

            if ($null -ne $Results.B2BDirectConnectOutbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BDirectConnectOutbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BDirectConnectOutbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BDirectConnectOutbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BDirectConnectOutbound') | Out-Null
                }
            }

            if ($null -ne $Results.InboundTrust)
            {
                $complexMapping = @(
                    @{
                        Name            = 'InboundTrust'
                        CimInstanceName = 'AADCrossTenantAccessPolicyInboundTrust'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.InboundTrust `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyInboundTrust' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.InboundTrust = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('InboundTrust') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('B2BCollaborationInbound', 'B2BCollaborationOutbound', 'B2BDirectConnectInbound', 'B2BDirectConnectOutbound', 'InboundTrust', 'AutomaticUserConsentSettings')

            # Fix OrganizationName variable in CIMInstance
            $currentDSCBlock = $currentDSCBlock.Replace('@$OrganizationName''', "@' + `$OrganizationName")

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

function Update-M365DSCSettingUserIdFromUPN
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Setting
    )

    if ($null -ne $Setting.UsersAndGroups -and $null -ne $Setting.UsersAndGroups.Targets)
    {
        for ($i = 0; $i -le $Setting.UsersAndGroups.Targets.Length; $i++)
        {
            $user = $Setting.UsersAndGroups.Targets[$i]
            $userValue = $user.Target
            if ($null -ne $userValue)
            {
                if ($user.TargetType -eq 'User')
                {
                    Write-Verbose -Message "Detected User type with UPN {$($user.Target)}"
                    $user = Get-MgUser -UserId $user.Target -ErrorAction SilentlyContinue
                    if ($null -ne $user)
                    {
                        $userValue = $user.Id
                    }
                }
                elseif ($user.TargetType -eq 'Group')
                {
                    Write-Verbose -Message "Detected Group type with Name {$($user.Target)}"
                    $group = Get-MgGroup -Filter "DisplayName eq  '$($user.Target)'" -ErrorAction SilentlyContinue
                    if ($null -ne $group)
                    {
                        $userValue = $group.Id
                    }
                }
            }
            if ($null -ne $userValue)
            {
                Write-Verbose -Message "Updating principal to Id {$userValue}"
            }
            if ($null -ne $Setting.UsersAndGroups.Targets[$i].Target)
            {
                $Setting.UsersAndGroups.Targets[$i].Target = $userValue
            }
        }
    }
    return $Setting
}

function Get-M365DSCAADCrossTenantAccessPolicyB2BSetting
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Setting
    )

    #region Applications
    $applications = @{
        AccessType = $Setting.applications.accessType
    }

    if ($null -ne $Setting.applications.targets)
    {
        $targets = @()
        foreach ($currentTarget in $Setting.applications.targets)
        {
            $targets += @{
                Target     = $currentTarget.target
                TargetType = $currentTarget.targetType
            }
        }
        $applications.Add('Targets', $targets)
    }
    #endregion

    #region UsersAndGroups
    $usersAndGroups = @{
        AccessType = $Setting.usersAndGroups.accessType
    }

    if ($null -ne $Setting.usersAndGroups.targets)
    {
        $targets = @()
        foreach ($currentTarget in $Setting.usersAndGroups.targets)
        {
            if ($currentTarget.targetType -eq 'User')
            {
                $user = Get-MgUser -UserId $currentTarget.target -ErrorAction SilentlyContinue
            }
            elseif ($currentTarget.targetType -eq 'Group')
            {
                $group = Get-MgGroup -GroupId $currentTarget.target -ErrorAction SilentlyContinue
            }

            $targetValue = $currentTarget.target
            if ($null -ne $user)
            {
                $targetValue = $user.UserPrincipalName
            }
            elseif ($null -ne $group)
            {
                $targetValue = $group.DisplayName
            }
            $targets += @{
                Target     = $targetValue
                TargetType = $currentTarget.targetType
            }
        }
        $usersAndGroups.Add('Targets', $targets)
    }
    #endregion
    $results = @{
        Applications   = $applications
        UsersAndGroups = $usersAndGroups
    }

    return $results
}

function Get-M365DSCAADCrossTenantAccessPolicyAutomaticUserConsentSettings
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Setting
    )

    $result = @{
        InboundAllowed  = $Setting.InboundAllowed
        OutboundAllowed = $Setting.OutboundAllowed
    }

    return $result
}

function Get-M365DSCAADCrossTenantAccessPolicyInboundTrust
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Setting
    )

    $result = @{
        IsCompliantDeviceAccepted           = $Setting.isCompliantDeviceAccepted
        IsHybridAzureADJoinedDeviceAccepted = $Setting.isHybridAzureADJoinedDeviceAccepted
        IsMfaAccepted                       = $Setting.isMfaAccepted
    }

    return $result
}

function Test-M365DSCB2BIsDefault
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $B2BSetting
    )

    if ($null -eq $B2BSetting.Applications.AccessType -and `
        $null -eq $B2BSetting.Applications.Target -and `
        $null -eq $B2BSetting.UsersAndGroups.AccessType -and `
        $null -eq $B2BSetting.UsersAndGroups.Target)
    {
        return $true
    }

    return $false
}

Export-ModuleMember -Function *-TargetResource
