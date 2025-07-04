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
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ApplySensitivityLabel,

        [Parameter()]
        [System.String[]]
        $ExchangeSender,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderException,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $AddExchangeLocation,

        [Parameter()]
        [System.String[]]
        $RemoveExchangeLocation,

        [Parameter()]
        [System.String]
        [ValidateSet('Enable', 'Disable', 'TestWithNotifications', 'TestWithoutNotifications')]
        $Mode,

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocationException,

        [Parameter()]
        [System.Int32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocation,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocation,

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Name -ne $Name)
        {
            Write-Verbose -Message "Getting configuration of Auto sensitivity Label Policy for $Name"

            $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
                -InboundParameters $PSBoundParameters

            #region Telemetry
            $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
            $CommandName = $MyInvocation.MyCommand
            $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
                -CommandName $CommandName `
                -Parameters $PSBoundParameters
            Add-M365DSCTelemetryEvent -Data $data
            #endregion

            $nullReturn = @{
                Ensure = 'Absent'
                Name = $Name
            }
            try
            {
                # There is a bug with the Get-AutoSensitivityLabelPolicy where if you get by Identity, the priority is an invalid number.
                # Threfore we get it by name.
                $policy = Get-AutoSensitivityLabelPolicy | Where-Object -FilterScript { $_.Name -eq $Name }
            }
            catch
            {
                throw $_
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Auto Sensitivity label policy $($Name) does not exist."
                return $nullReturn
            }
        }
        else
        {
            $policy = $Script:exportedInstance
        }

        Write-Verbose "Found existing Auto Sensitivity label policy $($Name)"
        $result = @{
            Name                              = $policy.Name
            Comment                           = $policy.Comment
            ApplySensitivityLabel             = $policy.ApplySensitivityLabel
            Credential                        = $Credential
            Ensure                            = 'Present'
            ExchangeSender                    = $policy.ExchangeSender
            ExchangeSenderException           = $policy.ExchangeSenderException
            ExchangeSenderMemberOf            = $policy.ExchangeSenderMemberOf
            ExchangeSenderMemberOfException   = $policy.ExchangeSenderMemberOfException
            ExchangeLocation                  = $policy.ExchangeLocation.Name
            AddExchangeLocation               = $policy.AddExchangeLocation
            RemoveExchangeLocation            = $policy.RemoveExchangeLocation
            Mode                              = $policy.Mode
            OneDriveLocation                  = $policy.OneDriveLocation.Name
            AddOneDriveLocation               = $policy.AddOneDriveLocation
            RemoveOneDriveLocation            = $policy.RemoveOneDriveLocation
            OneDriveLocationException         = $policy.OneDriveLocationException.Name
            AddOneDriveLocationException      = $policy.AddOneDriveLocationException
            RemoveOneDriveLocationException   = $policy.RemoveOneDriveLocationException
            Priority                          = $policy.Priority
            SharePointLocation                = $policy.SharePointLocation.Name
            SharePointLocationException       = $policy.SharePointLocationException
            AddSharePointLocationException    = $policy.AddSharePointLocationException
            RemoveSharePointLocationException = $policy.RemoveSharePointLocationException
            AddSharePointLocation             = $policy.AddSharePointLocation
            RemoveSharePointLocation          = $policy.RemoveSharePointLocation
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            CertificateThumbprint             = $CertificateThumbprint
            CertificatePath                   = $CertificatePath
            CertificatePassword               = $CertificatePassword
            AccessTokens                      = $AccessTokens
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
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ApplySensitivityLabel,

        [Parameter()]
        [System.String[]]
        $ExchangeSender,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderException,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $AddExchangeLocation,

        [Parameter()]
        [System.String[]]
        $RemoveExchangeLocation,

        [Parameter()]
        [System.String]
        [ValidateSet('Enable', 'Disable', 'TestWithNotifications', 'TestWithoutNotifications')]
        $Mode,

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocationException,

        [Parameter()]
        [System.Int32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocation,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocation,

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Setting configuration of Sensitivity label policy for $Name"

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
        -InboundParameters $PSBoundParameters

    $CurrentPolicy = Get-TargetResource @PSBoundParameters

    if ($PSBoundParameters.ContainsKey('SharePointLocation') -or $PSBoundParameters.ContainsKey('OneDriveLocation'))
    {
        if ($PSBoundParameters.ContainsKey('Mode') -eq $false)
        {
            Write-Verbose 'SharePoint or OneDrive location has been specified. Setting Mode to TestWithoutNotifications.'
            $PSBoundParameters.Add('Mode', 'TestWithoutNotifications')
        }
        elseif ($PSBoundParameters.Mode -eq 'Enable')
        {
            Write-Verbose 'SharePoint or OneDrive location has been specified. Changing Mode to TestWithoutNotifications.'
            $PSBoundParameters.Mode = 'TestWithoutNotifications'
        }
    }

    if (('Present' -eq $Ensure) -and ('Absent' -eq $CurrentPolicy.Ensure))
    {
        Write-Verbose "Creating new Auto Sensitivity label policy $Name."

        $CreationParams = $PSBoundParameters

        #Remove parameters not used in New-LabelPolicy
        $CreationParams.Remove('Ensure') | Out-Null
        $CreationParams.Remove('AddExchangeLocation') | Out-Null
        $CreationParams.Remove('AddOneDriveLocation') | Out-Null
        $CreationParams.Remove('AddOneDriveLocationException') | Out-Null
        $CreationParams.Remove('AddSharePointLocation') | Out-Null
        $CreationParams.Remove('AddSharePointLocationException') | Out-Null
        $CreationParams.Remove('RemoveExchangeLocation') | Out-Null
        $CreationParams.Remove('RemoveOneDriveLocation') | Out-Null
        $CreationParams.Remove('RemoveOneDriveLocationException') | Out-Null
        $CreationParams.Remove('RemoveSharePointLocation') | Out-Null
        $CreationParams.Remove('RemoveSharePointLocationException') | Out-Null

        # Remove authentication parameters
        $CreationParams.Remove('Credential') | Out-Null
        $CreationParams.Remove('ApplicationId') | Out-Null
        $CreationParams.Remove('TenantId') | Out-Null
        $CreationParams.Remove('CertificatePath') | Out-Null
        $CreationParams.Remove('CertificatePassword') | Out-Null
        $CreationParams.Remove('CertificateThumbprint') | Out-Null
        $CreationParams.Remove('ManagedIdentity') | Out-Null
        $CreationParams.Remove('ApplicationSecret') | Out-Null
        $CreationParams.Remove('AccessTokens') | Out-Null

        try
        {
            New-AutoSensitivityLabelPolicy @CreationParams
        }
        catch
        {
            Write-Warning "New-AutoSensitivityLabelPolicy is not available in tenant $($Credential.UserName.Split('@')[0])"
        }
        try
        {
            Start-Sleep 5
            $SetParams = $PSBoundParameters

            #Remove unused parameters for Set-Label cmdlet
            $SetParams.Remove('Ensure') | Out-Null
            $SetParams.Remove('Name') | Out-Null
            $SetParams.Remove('ExchangeLocationException') | Out-Null
            $SetParams.Remove('ExchangeLocation') | Out-Null
            $SetParams.Remove('OneDriveLocation') | Out-Null
            $SetParams.Remove('OneDriveLocationException') | Out-Null
            $SetParams.Remove('SharePointLocation') | Out-Null
            $SetParams.Remove('SharePointLocationException') | Out-Null

            # Remove authentication parameters
            $SetParams.Remove('Credential') | Out-Null
            $SetParams.Remove('ApplicationId') | Out-Null
            $SetParams.Remove('TenantId') | Out-Null
            $SetParams.Remove('CertificatePath') | Out-Null
            $SetParams.Remove('CertificatePassword') | Out-Null
            $SetParams.Remove('CertificateThumbprint') | Out-Null
            $SetParams.Remove('ManagedIdentity') | Out-Null
            $SetParams.Remove('ApplicationSecret') | Out-Null
            $SetParams.Remove('AccessTokens') | Out-Null

            Set-AutoSensitivityLabelPolicy @SetParams -Identity $Name
        }
        catch
        {
            Write-Warning "Set-AutoSensitivityLabelPolicy is not available in tenant $($Credential.UserName.Split('@')[0])"
        }
    }
    elseif (('Present' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        $SetParams = $PSBoundParameters

        #Remove unused parameters for Set-Label cmdlet
        $SetParams.Remove('Ensure') | Out-Null
        $SetParams.Remove('Name') | Out-Null
        $SetParams.Remove('ExchangeLocationException') | Out-Null
        $SetParams.Remove('ExchangeLocation') | Out-Null
        $SetParams.Remove('OneDriveLocation') | Out-Null
        $SetParams.Remove('OneDriveLocationException') | Out-Null
        $SetParams.Remove('SharePointLocation') | Out-Null
        $SetParams.Remove('SharePointLocationException') | Out-Null

        # Remove authentication parameters
        $SetParams.Remove('Credential') | Out-Null
        $SetParams.Remove('ApplicationId') | Out-Null
        $SetParams.Remove('TenantId') | Out-Null
        $SetParams.Remove('CertificatePath') | Out-Null
        $SetParams.Remove('CertificatePassword') | Out-Null
        $SetParams.Remove('CertificateThumbprint') | Out-Null
        $SetParams.Remove('ManagedIdentity') | Out-Null
        $SetParams.Remove('ApplicationSecret') | Out-Null
        $SetParams.Remove('AccessTokens') | Out-Null

        try
        {
            Set-AutoSensitivityLabelPolicy @SetParams -Identity $Name
        }
        catch
        {
            Write-Warning "Set-AutoSensitivityLabelPolicy is not available in tenant $($Credential.UserName.Split('@')[0])"
        }
    }
    elseif (('Absent' -eq $Ensure) -and ('Present' -eq $CurrentPolicy.Ensure))
    {
        # If the label exists and it shouldn't, simply remove it;Need to force deletoion
        Write-Verbose -Message "Deleting Auto Sensitivity label policy $Name."

        try
        {
            Remove-AutoSensitivityLabelPolicy -Identity $Name -Confirm:$false
        }
        catch
        {
            Write-Warning "Remove-AutoSensitivityLabelPolicy is not available in tenant $($Credential.UserName.Split('@')[0])"
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
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ApplySensitivityLabel,

        [Parameter()]
        [System.String[]]
        $ExchangeSender,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderException,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOf,

        [Parameter()]
        [System.String[]]
        $ExchangeSenderMemberOfException,

        [Parameter()]
        [System.String[]]
        $ExchangeLocation,

        [Parameter()]
        [System.String[]]
        $AddExchangeLocation,

        [Parameter()]
        [System.String[]]
        $RemoveExchangeLocation,

        [Parameter()]
        [System.String]
        [ValidateSet('Enable', 'Disable', 'TestWithNotifications', 'TestWithoutNotifications')]
        $Mode,

        [Parameter()]
        [System.String[]]
        $OneDriveLocation,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocation,

        [Parameter()]
        [System.String[]]
        $OneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $AddOneDriveLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveOneDriveLocationException,

        [Parameter()]
        [System.Int32]
        $Priority,

        [Parameter()]
        [System.String[]]
        $SharePointLocation,

        [Parameter()]
        [System.String[]]
        $SharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocationException,

        [Parameter()]
        [System.String[]]
        $AddSharePointLocation,

        [Parameter()]
        [System.String[]]
        $RemoveSharePointLocation,

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message "Testing configuration of Sensitivity label for $Name"
    $CurrentValues = Get-TargetResource @PSBoundParameters

    $ValuesToCheck = $PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

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
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    $ConnectionMode = New-M365DSCConnection -Workload 'SecurityComplianceCenter' `
        -InboundParameters $PSBoundParameters

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
        [array]$policies = Get-AutoSensitivityLabelPolicy -ErrorAction Stop

        $dscContent = ''
        $i = 1
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

            $Script:exportedInstance = $policy
            $Results = Get-TargetResource @PSBoundParameters -Name $policy.Name

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
        }
    }
    catch
    {
        if ($_.Exception.Message -like '*is not recognized as the name of a cmdlet*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for this feature."
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
    return $dscContent
}

Export-ModuleMember -Function *-TargetResource
