function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('android', 'androidForWork', 'iOS', 'macOS', 'windowsPhone81', 'windows81AndLater', 'windows10AndLater', 'androidWorkProfile', 'unknown', 'androidAOSP', 'androidMobileApplicationManagement', 'iOSMobileApplicationManagement', 'unknownFutureValue')]
        [System.String]
        $Platform,

        [Parameter()]
        [System.String]
        $Rule,

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

    Write-Verbose -Message "Getting configuration of the Intune Device and App Management Assignment Filter with Id {$Identity} and DisplayName {$DisplayName}"

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters `
                -ErrorAction Stop

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

            $nullResult = @{
                DisplayName = $DisplayName
                Ensure      = 'Absent'
            }

            if (-not [System.String]::IsNullOrEmpty($Identity))
            {
                Write-Verbose -Message "Checking if filter exists with identity {$Identity}."
                $assignmentFilter = Get-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $Identity -ErrorAction 'SilentlyContinue'
            }

            if ($null -eq $assignmentFilter)
            {
                Write-Verbose -Message "No assignment filter with Identity {$Identity} was found."

                Write-Verbose -Message "Checking if filter exists with DisplayName {$DisplayName}."
                [array]$assignmentFilter = Get-MgBetaDeviceManagementAssignmentFilter -All | Where-Object -FilterScript { $_.DisplayName -eq $DisplayName }
                if ($assignmentFilter.Length -gt 2)
                {
                    Write-Error -Message "More than one Assignment Filter found with name {$DisplayName}"
                }
                elseif ($assignmentFilter.Length -eq 0)
                {
                    Write-Verbose -Message "No assignment filter with name {$DisplayName} was found."
                    return $nullResult
                }
            }
        }
        else
        {
            $assignmentFilter = $Script:exportedInstance
        }

        Write-Verbose -Message "Found assignment filter {$($assignmentFilter.displayName)}"

        $returnHashtable = @{}
        $returnHashtable.Add('Identity', $assignmentFilter.Id)
        $returnHashtable.Add('DisplayName', $assignmentFilter.displayName)
        $returnHashtable.Add('Description', $assignmentFilter.description)
        $returnHashtable.Add('Platform', $assignmentFilter.platform.ToString())
        $returnHashtable.Add('Rule', $assignmentFilter.rule)
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

        return $nullResult
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('android', 'androidForWork', 'iOS', 'macOS', 'windowsPhone81', 'windows81AndLater', 'windows10AndLater', 'androidWorkProfile', 'unknown', 'androidAOSP', 'androidMobileApplicationManagement', 'iOSMobileApplicationManagement', 'unknownFutureValue')]
        [System.String]
        $Platform,

        [Parameter()]
        [System.String]
        $Rule,

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

    Write-Verbose -Message "Setting the Intune Device and App Management Assignment Filter {$DisplayName}"

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

    $currentPolicy = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new assignment filter {$DisplayName}"

        New-MgBetaDeviceManagementAssignmentFilter `
            -DisplayName $DisplayName `
            -Description $Description `
            -Platform $Platform `
            -Rule $Rule | Out-Null

    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing assignment filter {$DisplayName}"

        Update-MgBetaDeviceManagementAssignmentFilter `
            -DeviceAndAppManagementAssignmentFilterId $currentPolicy.Identity `
            -DisplayName $DisplayName `
            -Description $Description `
            -Rule $Rule | Out-Null

    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing assignment filter {$DisplayName}"
        Remove-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $currentPolicy.Identity | Out-Null
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('android', 'androidForWork', 'iOS', 'macOS', 'windowsPhone81', 'windows81AndLater', 'windows10AndLater', 'androidWorkProfile', 'unknown', 'androidAOSP', 'androidMobileApplicationManagement', 'iOSMobileApplicationManagement', 'unknownFutureValue')]
        [System.String]
        $Platform,

        [Parameter()]
        [System.String]
        $Rule,

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

    Write-Verbose -Message "Testing the Intune Device and App Management Assignment Filter {$DisplayName}"

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
    Write-Verbose -Message "Testing configuration of assignment filter {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $ValuesToCheck = Remove-M365DSCAuthenticationParameter -BoundParameters $ValuesToCheck
    $ValuesToCheck.Remove('Identity') | Out-Null
    $testResult = $true

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    if ($TestResult)
    {
        $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
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
        if (-not [string]::IsNullOrEmpty($Filter))
        {
            Write-Warning -Message 'Microsoft Graph filter is only supported for the platform on this resource. Other filters are only supported using startswith, endswith and contains and done by best-effort.'
            $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $Filter
            $Filter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $Filter
        }
        [array]$assignmentFilters = Get-MgBetaDeviceManagementAssignmentFilter -All:$true -Filter $Filter -ErrorAction Stop
        $assignmentFilters = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $assignmentFilters

        if ($policies.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }

        foreach ($assignmentFilter in $assignmentFilters)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($assignmentFilters.Count)] $($assignmentFilter.displayName)" -DeferWrite

            $params = @{
                DisplayName           = $assignmentFilter.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $assignmentFilter
            $Results = Get-TargetResource @Params
            if ($Results.Ensure -eq 'Present')
            {
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
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like '*Request not applicable to target tenant*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
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

Export-ModuleMember -Function *-TargetResource, *
