function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DetectionScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DetectionScriptParameters,

        [Parameter()]
        [ValidateSet('deviceHealthScript', 'managedInstallerScript')]
        [System.String]
        $DeviceHealthScriptType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.Boolean]
        $EnforceSignatureCheck,

        [Parameter()]
        [System.Boolean]
        $IsGlobalScript,

        [Parameter()]
        [System.String]
        $Publisher,

        [Parameter()]
        [System.String]
        $RemediationScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RemediationScriptParameters,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $RunAs32Bit,

        [Parameter()]
        [ValidateSet('system', 'user')]
        [System.String]
        $RunAsAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion

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

    Write-Verbose -Message "Getting configuration of the Intune Device Remediation with Id {$Id} and DisplayName {$DisplayName}"

    try
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

        $getValue = $null
        #region resource generator code
        $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $Id -ErrorAction SilentlyContinue

        if ($null -eq $getValue)
        {
            Write-Verbose -Message "Could not find an Intune Device Remediation with Id {$Id}"

            if (-Not [string]::IsNullOrEmpty($DisplayName))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceHealthScript `
                    -All `
                    -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                    -ErrorAction SilentlyContinue | Where-Object `
                    -FilterScript { `
                        $_.DeviceHealthScriptType -eq 'deviceHealthScript' `
                }
                if ($null -ne $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $getValue.Id
                }
            }
        }
        #endregion
        if ($null -eq $getValue)
        {
            Write-Verbose -Message "Could not find an Intune Device Remediation with DisplayName {$DisplayName}"
            return $nullResult
        }
        $Id = $getValue.Id
        Write-Verbose -Message "An Intune Device Remediation with Id {$Id} and DisplayName {$DisplayName} was found."

        #region resource generator code
        $complexDetectionScriptParameters = @()
        foreach ($currentDetectionScriptParameters in $getValue.detectionScriptParameters)
        {
            $myDetectionScriptParameters = @{}
            $myDetectionScriptParameters.Add('ApplyDefaultValueWhenNotAssigned', $currentDetectionScriptParameters.applyDefaultValueWhenNotAssigned)
            $myDetectionScriptParameters.Add('Description', $currentDetectionScriptParameters.description)
            $myDetectionScriptParameters.Add('IsRequired', $currentDetectionScriptParameters.isRequired)
            $myDetectionScriptParameters.Add('Name', $currentDetectionScriptParameters.name)
            $myDetectionScriptParameters.Add('DefaultValue', $currentDetectionScriptParameters.defaultValue)
            if ($null -ne $currentDetectionScriptParameters.'@odata.type')
            {
                $myDetectionScriptParameters.Add('odataType', $currentDetectionScriptParameters.'@odata.type'.toString())
            }
            if ($myDetectionScriptParameters.values.Where({ $null -ne $_ }).count -gt 0)
            {
                $complexDetectionScriptParameters += $myDetectionScriptParameters
            }
        }

        $complexRemediationScriptParameters = @()
        foreach ($currentRemediationScriptParameters in $getValue.remediationScriptParameters)
        {
            $myRemediationScriptParameters = @{}
            $myRemediationScriptParameters.Add('ApplyDefaultValueWhenNotAssigned', $currentRemediationScriptParameters.applyDefaultValueWhenNotAssigned)
            $myRemediationScriptParameters.Add('Description', $currentRemediationScriptParameters.description)
            $myRemediationScriptParameters.Add('IsRequired', $currentRemediationScriptParameters.isRequired)
            $myRemediationScriptParameters.Add('Name', $currentRemediationScriptParameters.name)
            $myRemediationScriptParameters.Add('DefaultValue', $currentRemediationScriptParameters.defaultValue)
            if ($null -ne $currentRemediationScriptParameters.'@odata.type')
            {
                $myRemediationScriptParameters.Add('odataType', $currentRemediationScriptParameters.'@odata.type'.toString())
            }
            if ($myRemediationScriptParameters.values.Where({ $null -ne $_ }).count -gt 0)
            {
                $complexRemediationScriptParameters += $myRemediationScriptParameters
            }
        }
        #endregion

        #region resource generator code
        $enumDeviceHealthScriptType = $null
        if ($null -ne $getValue.DeviceHealthScriptType)
        {
            $enumDeviceHealthScriptType = $getValue.DeviceHealthScriptType.ToString()
        }

        $enumRunAsAccount = $null
        if ($null -ne $getValue.RunAsAccount)
        {
            $enumRunAsAccount = $getValue.RunAsAccount.ToString()
        }
        #endregion

        $results = @{
            #region resource generator code
            Description                 = $getValue.Description
            DetectionScriptContent      = [System.Convert]::ToBase64String($getValue.DetectionScriptContent)
            DetectionScriptParameters   = $complexDetectionScriptParameters
            DeviceHealthScriptType      = $enumDeviceHealthScriptType
            DisplayName                 = $getValue.DisplayName
            EnforceSignatureCheck       = $getValue.EnforceSignatureCheck
            IsGlobalScript              = $getValue.IsGlobalScript
            Publisher                   = $getValue.Publisher
            RemediationScriptContent    = [System.Convert]::ToBase64String($getValue.RemediationScriptContent)
            RemediationScriptParameters = $complexRemediationScriptParameters
            RoleScopeTagIds             = $getValue.RoleScopeTagIds
            RunAs32Bit                  = $getValue.RunAs32Bit
            RunAsAccount                = $enumRunAsAccount
            Id                          = $getValue.Id
            Ensure                      = 'Present'
            Credential                  = $Credential
            ApplicationId               = $ApplicationId
            TenantId                    = $TenantId
            ApplicationSecret           = $ApplicationSecret
            CertificateThumbprint       = $CertificateThumbprint
            ManagedIdentity             = $ManagedIdentity.IsPresent
            AccessTokens                = $AccessTokens
            #endregion
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceHealthScriptAssignment -DeviceHealthScriptId $Id
        $assignmentResult = @()
        foreach ($assignment in $assignmentsValues)
        {
            if (-not [System.String]::IsNullOrEmpty($assignment.RunSchedule.AdditionalProperties.time))
            {
                $time = Get-Date -Format 'HH:mm:ss' -Date $assignment.RunSchedule.AdditionalProperties.time
            }
            else
            {
                $time = $null
            }

            $assignmentResult += @{
                RunRemediationScript = $assignment.RunRemediationScript
                RunSchedule          = @{
                    DataType = $assignment.RunSchedule.AdditionalProperties.'@odata.type'
                    Date     = $assignment.RunSchedule.AdditionalProperties.date
                    Interval = $assignment.RunSchedule.Interval
                    Time     = $time
                    UseUtc   = $assignment.RunSchedule.AdditionalProperties.useUtc
                }
                Assignment           = (ConvertFrom-IntunePolicyAssignment `
                        -IncludeDeviceFilter:$true `
                        -Assignments $assignment) | Select-Object -First 1
            }
        }
        $results.Add('Assignments', $assignmentResult)

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
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DetectionScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DetectionScriptParameters,

        [Parameter()]
        [ValidateSet('deviceHealthScript', 'managedInstallerScript')]
        [System.String]
        $DeviceHealthScriptType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.Boolean]
        $EnforceSignatureCheck,

        [Parameter()]
        [System.Boolean]
        $IsGlobalScript,

        [Parameter()]
        [System.String]
        $Publisher,

        [Parameter()]
        [System.String]
        $RemediationScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RemediationScriptParameters,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $RunAs32Bit,

        [Parameter()]
        [ValidateSet('system', 'user')]
        [System.String]
        $RunAsAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion
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

    $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $PSBoundParameters
    $BoundParameters.Remove('IsGlobalScript') | Out-Null

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating an Intune Device Remediation with DisplayName {$DisplayName}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $CreateParameters = ([Hashtable]$BoundParameters).Clone()
        $CreateParameters = Rename-M365DSCCimInstanceParameter -Properties $CreateParameters
        $CreateParameters.DetectionScriptContent = [System.Convert]::FromBase64String($CreateParameters.DetectionScriptContent)
        $CreateParameters.RemediationScriptContent = [System.Convert]::FromBase64String($CreateParameters.RemediationScriptContent)
        $CreateParameters.Remove('Id') | Out-Null

        $keys = (([Hashtable]$CreateParameters).Clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $CreateParameters.$key -and $CreateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $CreateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters.$key
            }
        }
        #region resource generator code
        $policy = New-MgBetaDeviceManagementDeviceHealthScript -BodyParameter $CreateParameters
        $assignmentsHash = @()
        foreach ($assignment in $Assignments)
        {
            $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment.Assignment
            $runSchedule = $null
            if ($null -ne $assignment.RunSchedule.DataType)
            {
                $runSchedule = @{
                    '@odata.type' = $assignment.RunSchedule.DataType
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Date))
                {
                    $runSchedule.Add('date', $assignment.RunSchedule.Date)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Interval))
                {
                    $runSchedule.Add('interval', $assignment.RunSchedule.Interval)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Time))
                {
                    $runSchedule.Add('time', $assignment.RunSchedule.Time)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.UseUtc))
                {
                    $runSchedule.Add('useUtc', $assignment.RunSchedule.UseUtc)
                }
            }
            $assignmentsHash += @{
                runRemediationScript = $assignment.RunRemediationScript
                runSchedule          = $runSchedule
                target               = $assignmentTarget.target
            }
        }

        if ($policy.Id)
        {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceHealthScripts' `
                -RootIdentifier 'deviceHealthScriptAssignments'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Intune Device Remediation with Id {$($currentInstance.Id)}"
        $BoundParameters.Remove('Assignments') | Out-Null

        $UpdateParameters = ([Hashtable]$BoundParameters).Clone()
        $UpdateParameters = Rename-M365DSCCimInstanceParameter -Properties $UpdateParameters
        $UpdateParameters.DetectionScriptContent = [System.Convert]::FromBase64String($UpdateParameters.DetectionScriptContent)
        $UpdateParameters.RemediationScriptContent = [System.Convert]::FromBase64String($UpdateParameters.RemediationScriptContent)
        $UpdateParameters.Remove('DeviceHealthScriptType') | Out-Null
        $UpdateParameters.Remove('Id') | Out-Null

        if ($currentInstance.IsGlobalScript)
        {
            Write-Warning -Message "The Intune Device Remediation with Id {$($currentInstance.Id)} is a global script and only few properties can be updated."
            $UpdateParameters = @{
                Id              = $currentInstance.Id
                RoleScopeTagIds = $RoleScopeTagIds
                RunAs32Bit      = $RunAs32Bit
                RunAsAccount    = $RunAsAccount
            }
        }

        $keys = (([Hashtable]$UpdateParameters).Clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $UpdateParameters.$key -and $UpdateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $UpdateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters.$key
            }
        }
        #region resource generator code
        Update-MgBetaDeviceManagementDeviceHealthScript  `
            -DeviceHealthScriptId $currentInstance.Id `
            -BodyParameter $UpdateParameters

        $assignmentsHash = @()
        foreach ($assignment in $Assignments)
        {
            $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment.Assignment
            $runSchedule = $null
            if ($null -ne $assignment.RunSchedule.DataType)
            {
                $runSchedule = @{
                    '@odata.type' = $assignment.RunSchedule.DataType
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Date))
                {
                    $runSchedule.Add('date', $assignment.RunSchedule.Date)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Interval))
                {
                    $runSchedule.Add('interval', $assignment.RunSchedule.Interval)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Time))
                {
                    $runSchedule.Add('time', $assignment.RunSchedule.Time)
                }
                if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.UseUtc))
                {
                    $runSchedule.Add('useUtc', $assignment.RunSchedule.UseUtc)
                }
            }
            $assignmentsHash += @{
                runRemediationScript = $assignment.RunRemediationScript
                runSchedule          = $runSchedule
                target               = $assignmentTarget.target
            }
        }
        Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.Id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/deviceHealthScripts' `
            -RootIdentifier 'deviceHealthScriptAssignments'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        if ($currentInstance.IsGlobalScript)
        {
            throw "The Intune Device Remediation with Id {$($currentInstance.Id)} is a global script and cannot be removed."
        }
        Write-Verbose -Message "Removing the Intune Device Remediation with Id {$($currentInstance.Id)}"
        #region resource generator code
        Remove-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $currentInstance.Id
        #endregion
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        #region resource generator code
        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $DetectionScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DetectionScriptParameters,

        [Parameter()]
        [ValidateSet('deviceHealthScript', 'managedInstallerScript')]
        [System.String]
        $DeviceHealthScriptType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.Boolean]
        $EnforceSignatureCheck,

        [Parameter()]
        [System.Boolean]
        $IsGlobalScript,

        [Parameter()]
        [System.String]
        $Publisher,

        [Parameter()]
        [System.String]
        $RemediationScriptContent,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $RemediationScriptParameters,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Boolean]
        $RunAs32Bit,

        [Parameter()]
        [ValidateSet('system', 'user')]
        [System.String]
        $RunAsAccount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Id,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,
        #endregion

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

    Write-Verbose -Message "Testing configuration of the Intune Device Remediation with Id {$Id} and DisplayName {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testResult = $true

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($null -ne $source -and $source.GetType().Name -like '*CimInstance*')
        {
            $testResult = Compare-M365DSCComplexObject `
                -Source ($source) `
                -Target ($target)

            if (-not $testResult)
            {
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }

    $ValuesToCheck.Remove('Id') | Out-Null
    $ValuesToCheck.Remove('IsGlobalScript') | Out-Null
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck

    if ($CurrentValues.IsGlobalScript)
    {
        Write-Verbose -Message 'Detected a global script, removing read-only properties from the comparison'
        $ValuesToCheck.Remove('DetectionScriptContent') | Out-Null
        $ValuesToCheck.Remove('RemediationScriptContent') | Out-Null
        $ValuesToCheck.Remove('DetectionScriptParameters') | Out-Null
        $ValuesToCheck.Remove('RemediationScriptParameters') | Out-Null
        $ValuesToCheck.Remove('DeviceHealthScriptType') | Out-Null
        $ValuesToCheck.Remove('Publisher') | Out-Null
        $ValuesToCheck.Remove('EnforceSignatureCheck') | Out-Null
        $ValuesToCheck.Remove('DisplayName') | Out-Null
        $ValuesToCheck.Remove('Description') | Out-Null
    }

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        #region resource generator code
        # Only export scripts that are not from Microsoft
        [array]$getValue = Get-MgBetaDeviceManagementDeviceHealthScript `
            -Filter $Filter `
            -All `
            -ErrorAction Stop
        #endregion

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

            $displayedKey = $config.Id
            if (-not [String]::IsNullOrEmpty($config.DisplayName))
            {
                $displayedKey = $config.DisplayName
            }
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
            $params = @{
                Id                    = $config.Id
                DisplayName           = $config.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Results = Get-TargetResource @Params
            if ($null -ne $Results.DetectionScriptParameters)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.DetectionScriptParameters `
                    -CIMInstanceName 'MicrosoftGraphdeviceHealthScriptParameter'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.DetectionScriptParameters = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('DetectionScriptParameters') | Out-Null
                }
            }
            if ($null -ne $Results.RemediationScriptParameters)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.RemediationScriptParameters `
                    -CIMInstanceName 'MicrosoftGraphdeviceHealthScriptParameter'
                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.RemediationScriptParameters = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('RemediationScriptParameters') | Out-Null
                }
            }
            if ($Results.Assignments)
            {
                $complexMapping = @(
                    @{
                        Name            = 'RunSchedule'
                        CimInstanceName = 'IntuneDeviceRemediationRunSchedule'
                        IsRequired      = $false
                    }
                    @{
                        Name            = 'Assignment'
                        CimInstanceName = 'DeviceManagementConfigurationPolicyAssignments'
                        IsRequired      = $true
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.Assignments `
                    -CIMInstanceName 'MSFT_IntuneDeviceRemediationPolicyAssignments' `
                    -ComplexTypeMapping $complexMapping

                if (-not [string]::IsNullOrEmpty($complexTypeStringResult))
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
                -NoEscape @('DetectionScriptParameters', 'RemediationScriptParameters', 'Assignments')

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
