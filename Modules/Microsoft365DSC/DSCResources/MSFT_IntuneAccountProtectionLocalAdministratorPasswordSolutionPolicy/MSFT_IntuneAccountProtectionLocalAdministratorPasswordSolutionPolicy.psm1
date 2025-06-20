function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 2)]
        $BackupDirectory,

        [Parameter()]
        [System.Int32]
        [ValidateRange(7, 365)]
        $passwordagedays_aad,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 365)]
        $PasswordAgeDays,

        [Parameter()]
        [System.Boolean]
        $PasswordExpirationProtectionEnabled,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 12)]
        $AdEncryptedPasswordHistorySize,

        [Parameter()]
        [System.Boolean]
        $AdPasswordEncryptionEnabled,

        [Parameter()]
        [System.String]
        $AdPasswordEncryptionPrincipal,

        [Parameter()]
        [System.String]
        $AdministratorAccountName,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 8)]
        $PasswordComplexity,

        [Parameter()]
        [ValidateRange(3, 10)]
        [System.Int32]
        $PassphraseLength,

        [Parameter()]
        [System.Int32]
        [ValidateRange(8, 64)]
        $PasswordLength,

        [Parameter()]
        [System.Int32]
        [ValidateSet(1, 3, 5, 11)]
        $PostAuthenticationActions,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 24)]
        $PostAuthenticationResetDelay,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnabled,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $AutomaticAccountManagementTarget,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementRandomizeName,

        [Parameter()]
        [System.String]
        $AutomaticAccountManagementNameOrPrefix,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnableAccount,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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

    Write-Verbose -Message "Getting configuration of the Intune Account Protection LAPS Policy with Id {$Identity} and DisplayName {$DisplayName}"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters `
                -ErrorAction Stop

            #Ensure the proper dependencies are installed in the current environment.
            #Confirm-M365DSCDependencies

            #region Telemetry
            $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
            $CommandName = $MyInvocation.MyCommand
            $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
                -CommandName $CommandName `
                -Parameters $PSBoundParameters
            Add-M365DSCTelemetryEvent -Data $data
            #endregion

            $nullResult = $PSBoundParameters
            $nullResult.Ensure = 'Absent'

            $templateReferenceId = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'

            # Retrieve policy general settings
            $policy = $null
            if (-not [System.String]::IsNullOrEmpty($Identity))
            {
                $policy = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $Identity -ErrorAction SilentlyContinue
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "No Account Protection LAPS Policy with Id {$Identity} was found"

                if (-not [System.String]::IsNullOrEmpty($DisplayName))
                {
                    $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                        -Filter "Name eq '$($DisplayName -replace "'", "''")' and templateReference/TemplateId eq '$templateReferenceId'" `
                        -ErrorAction SilentlyContinue

                    if ($policy.Length -gt 1)
                    {
                        throw "Duplicate Account Protection LAPS Policy named $DisplayName exist in tenant"
                    }
                }
            }
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        if ($null -eq $policy)
        {
            Write-Verbose -Message "No Account Protection LAPS Policy with Name {$DisplayName} was found"
            return $nullResult
        }
        $Identity = $policy.Id
        Write-Verbose "Found Account Protection LAPS Policy with Id {$Identity} and Name {$($policy.Name)}"

        [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
            -DeviceManagementConfigurationPolicyId $Identity `
            -ExpandProperty 'settingDefinitions' `
            -ErrorAction Stop

        $returnHashtable = @{}
        $returnHashtable.Add('Identity', $Identity)
        $returnHashtable.Add('DisplayName', $policy.Name)
        $returnHashtable.Add('Description', $policy.Description)
        $returnHashtable.Add('RoleScopeTagIds', $policy.RoleScopeTagIds)

        $returnHashtable = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $returnHashtable

        if ($null -ne $returnHashtable.PasswordExpirationProtectionEnabled)
        {
            $returnHashtable.PasswordExpirationProtectionEnabled = [bool]::Parse($returnHashtable.PasswordExpirationProtectionEnabled)
        }

        if ($null -ne $returnHashtable.AdPasswordEncryptionEnabled)
        {
            $returnHashtable.AdPasswordEncryptionEnabled = [bool]::Parse($returnHashtable.AdPasswordEncryptionEnabled)
        }

        $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $policy.Id
        $assignmentResult = @()
        if ($assignmentsValues.Count -gt 0)
        {
            $assignmentResult += ConvertFrom-IntunePolicyAssignment -IncludeDeviceFilter $true -Assignments $assignmentsValues
        }
        $returnHashtable.Add('Assignments', $assignmentResult)

        $returnHashtable.Add('Ensure', 'Present')
        $returnHashtable.Add('Credential', $Credential)
        $returnHashtable.Add('ApplicationId', $ApplicationId)
        $returnHashtable.Add('TenantId', $TenantId)
        $returnHashtable.Add('ApplicationSecret', $ApplicationSecret)
        $returnHashtable.Add('CertificateThumbprint', $CertificateThumbprint)
        $returnHashtable.Add('ManagedIdentity', $ManagedIdentity.IsPresent)
        $returnHashtable.Add('AccessTokens', $AccessTokens)

        return $returnHashtable
    }
    catch
    {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        # Necessary to rethrow caught exception regarding duplicate policies
        if ($_.Exception.Message -like "Duplicate*")
        {
            throw $_
        }

        return $nullResult
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 2)]
        $BackupDirectory,

        [Parameter()]
        [System.Int32]
        [ValidateRange(7, 365)]
        $passwordagedays_aad,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 365)]
        $PasswordAgeDays,

        [Parameter()]
        [System.Boolean]
        $PasswordExpirationProtectionEnabled,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 12)]
        $AdEncryptedPasswordHistorySize,

        [Parameter()]
        [System.Boolean]
        $AdPasswordEncryptionEnabled,

        [Parameter()]
        [System.String]
        $AdPasswordEncryptionPrincipal,

        [Parameter()]
        [System.String]
        $AdministratorAccountName,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 8)]
        $PasswordComplexity,

        [Parameter()]
        [ValidateRange(3, 10)]
        [System.Int32]
        $PassphraseLength,

        [Parameter()]
        [System.Int32]
        [ValidateRange(8, 64)]
        $PasswordLength,

        [Parameter()]
        [System.Int32]
        [ValidateSet(1, 3, 5, 11)]
        $PostAuthenticationActions,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 24)]
        $PostAuthenticationResetDelay,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnabled,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $AutomaticAccountManagementTarget,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementRandomizeName,

        [Parameter()]
        [System.String]
        $AutomaticAccountManagementNameOrPrefix,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnableAccount,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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
    #Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentPolicy = Get-TargetResource @PSBoundParameters

    $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters

    $templateReferenceId = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'
    $platforms = 'windows10'
    $technologies = 'mdm'

    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Account Protection LAPS Policy {$DisplayName}"
        $BoundParameters.Remove('Assignments') | Out-Null
        $BoundParameters.Remove('Identity') | Out-Null

        $settings = Get-IntuneSettingCatalogPolicySetting `
            -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
            -TemplateId $templateReferenceId

        $createParameters = @{
            Name              = $DisplayName
            Description       = $Description
            TemplateReference = @{ templateId = $templateReferenceId }
            Platforms         = $platforms
            Technologies      = $technologies
            Settings          = $settings
        }
        $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

        if ($policy.Id)
        {
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
        }
    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing Account Protection LAPS Policy {$($currentPolicy.DisplayName)}"
        $BoundParameters.Remove('Assignments') | Out-Null
        $BoundParameters.Remove('Identity') | Out-Null

        #format settings from PSBoundParameters for update
        $settings = Get-IntuneSettingCatalogPolicySetting `
            -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
            -TemplateId $templateReferenceId

        Update-IntuneDeviceConfigurationPolicy `
            -DeviceConfigurationPolicyId $currentPolicy.Identity `
            -Name $DisplayName `
            -Description $Description `
            -TemplateReferenceId $templateReferenceId `
            -Platforms $platforms `
            -Technologies $technologies `
            -Settings $settings

        #region update policy assignments
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment `
            -DeviceConfigurationPolicyId $currentPolicy.Identity `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/configurationPolicies'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Account Protection LAPS Policy {$($currentPolicy.DisplayName)}"
        Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentPolicy.Identity
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 2)]
        $BackupDirectory,

        [Parameter()]
        [System.Int32]
        [ValidateRange(7, 365)]
        $passwordagedays_aad,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 365)]
        $PasswordAgeDays,

        [Parameter()]
        [System.Boolean]
        $PasswordExpirationProtectionEnabled,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 12)]
        $AdEncryptedPasswordHistorySize,

        [Parameter()]
        [System.Boolean]
        $AdPasswordEncryptionEnabled,

        [Parameter()]
        [System.String]
        $AdPasswordEncryptionPrincipal,

        [Parameter()]
        [System.String]
        $AdministratorAccountName,

        [Parameter()]
        [System.Int32]
        [ValidateRange(1, 8)]
        $PasswordComplexity,

        [Parameter()]
        [ValidateRange(3, 10)]
        [System.Int32]
        $PassphraseLength,

        [Parameter()]
        [System.Int32]
        [ValidateRange(8, 64)]
        $PasswordLength,

        [Parameter()]
        [System.Int32]
        [ValidateSet(1, 3, 5, 11)]
        $PostAuthenticationActions,

        [Parameter()]
        [System.Int32]
        [ValidateRange(0, 24)]
        $PostAuthenticationResetDelay,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnabled,

        [Parameter()]
        [ValidateSet('0', '1')]
        [System.String]
        $AutomaticAccountManagementTarget,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementRandomizeName,

        [Parameter()]
        [System.String]
        $AutomaticAccountManagementNameOrPrefix,

        [Parameter()]
        [ValidateSet('false', 'true')]
        [System.String]
        $AutomaticAccountManagementEnableAccount,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing configuration of Account Protection LAPS Policy {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    [Hashtable]$ValuesToCheck = @{}
    $MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        if ($_.Key -notlike '*Variable' -or $_.Key -notin @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction'))
        {
            if ($null -ne $CurrentValues[$_.Key] -or $null -ne $PSBoundParameters[$_.Key])
            {
                $ValuesToCheck.Add($_.Key, $null)
                if (-not $PSBoundParameters.ContainsKey($_.Key))
                {
                    $PSBoundParameters.Add($_.Key, $null)
                }
            }
        }
    }
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($null -ne $source -and $source.GetType().Name -like '*CimInstance*')
        {
            $source = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $source

            if ($key -eq 'Assignments')
            {
                $testResult = Compare-M365DSCIntunePolicyAssignment `
                    -Source $source `
                    -Target $target
            }
            else
            {
                $testResult = Compare-M365DSCComplexObject `
                    -Source ($source) `
                    -Target ($target)
            }

            if (-not $testResult)
            {
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck.Remove('Identity') | Out-Null
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

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
    param
    (
        [Parameter()]
        [System.String]
        $Filter,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $dscContent = ''
    $i = 1

    try
    {
        $policyTemplateID = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'
        [array]$policies = Get-MgBetaDeviceManagementConfigurationPolicy `
            -All:$true `
            -Filter $Filter `
            -ErrorAction Stop | Where-Object -FilterScript { $_.TemplateReference.TemplateId -eq $policyTemplateID }

        if ($policies.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($policy in $policies)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite

            $params = @{
                Identity              = $policy.Id
                DisplayName           = $policy.Name
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $policy
            $Results = Get-TargetResource @Params

            if ($Results.Assignments)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments
                if ($complexTypeStringResult)
                {
                    $Results.Assignments = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Assignments') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Assignments')

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
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*' -or `
                $_.Exception -like '*Request not applicable to target tenant*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune." -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            New-M365DSCLogEntry -Message 'Error during Export:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential
        }

        return ''
    }
}

Export-ModuleMember -Function *-TargetResource
