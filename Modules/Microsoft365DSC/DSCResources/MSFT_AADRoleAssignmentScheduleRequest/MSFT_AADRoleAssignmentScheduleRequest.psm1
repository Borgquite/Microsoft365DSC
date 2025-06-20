function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RoleDefinition,

        [Parameter(Mandatory = $true)]
        [ValidateSet('User', 'Group', 'ServicePrincipal')]
        [System.String]
        $PrincipalType,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DirectoryScopeId,

        [Parameter()]
        [System.String]
        $AppScopeId,

        [Parameter()]
        [ValidateSet('adminAssign', 'adminUpdate', 'adminRemove', 'selfActivate', 'selfDeactivate', 'adminExtend', 'adminRenew', 'selfExtend', 'selfRenew', 'unknownFutureValue')]
        [System.String]
        $Action,

        [Parameter()]
        [System.String]
        $Justification,

        [Parameter()]
        [System.Boolean]
        $IsValidationOnly,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ScheduleInfo,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $TicketInfo,

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
    try
    {
        $request = $null
        if (-not [System.String]::IsNullOrEmpty($Id))
        {
            if ($null -ne $Script:exportedInstances -and $Script:ExportMode)
            {
                $request = $Script:exportedInstances | Where-Object -FilterScript { $_.Id -eq $Id }
            }
            else
            {
                Write-Verbose -Message "Getting Role Eligibility by Id {$Id}"
                $request = Get-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest -UnifiedRoleAssignmentScheduleRequestId $Id `
                    -ErrorAction SilentlyContinue
            }
        }

        Write-Verbose -Message 'Getting Role Eligibility by PrincipalId and RoleDefinitionId'
        $PrincipalValue = $null
        if ($PrincipalType -eq 'User')
        {
            Write-Verbose -Message "Retrieving Principal by UserPrincipalName {$Principal}"
            $PrincipalInstance = Get-MgUser -Filter "UserPrincipalName eq '$($Principal -replace "'", "''")'" -ErrorAction SilentlyContinue
            $PrincipalValue = $PrincipalInstance.UserPrincipalName
        }
        elseif ($null -eq $PrincipalIdValue -and $PrincipalType -eq 'Group')
        {
            Write-Verbose -Message "Retrieving Principal by DisplayName {$Principal}"
            $PrincipalInstance = Get-MgGroup -Filter "DisplayName eq '$($Principal -replace "'", "''")'" -ErrorAction SilentlyContinue
            $PrincipalValue = $PrincipalInstance.DisplayName
        }
        else
        {
            Write-Verbose -Message "Retrieving Principal by DisplayName {$Principal}"
            $PrincipalInstance = Get-MgServicePrincipal -Filter "DisplayName eq '$($Principal -replace "'", "''")'" -ErrorAction SilentlyContinue
            $PrincipalValue = $PrincipalInstance.DisplayName
        }

        if ([System.String]::IsNullOrEmpty($PrincipalValue)) {
            return $nullResult
        }

        Write-Verbose -Message 'Found Principal'
        $RoleDefinitionId = (Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($RoleDefinition -replace "'", "''")'").Id
        Write-Verbose -Message "Retrieved role definition {$RoleDefinition} with ID {$RoleDefinitionId}"

        if ($null -eq $request)
        {
            Write-Verbose -Message "Retrieving the request by PrincipalId {$($PrincipalInstance.Id)}, RoleDefinitionId {$($RoleDefinitionId)} and DirectoryScopeId {$($DirectoryScopeId)}"
            [Array] $requests = Get-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest -Filter "PrincipalId eq '$($PrincipalInstance.Id)' and RoleDefinitionId eq '$($RoleDefinitionId)' and DirectoryScopeId eq '$($DirectoryScopeId)'"
            if ($requests.Length -eq 0)
            {
                Write-Verbose -Message "Trying to retrieve by reverse RoleId retrieval"
                $partialRequests = Get-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest -Filter "PrincipalId eq '$($PrincipalInstance.Id)' and DirectoryScopeId eq '$($DirectoryScopeId)'"
                $reverseRoleId = $null
                foreach ($partialRequest in $partialRequests)
                {
                    $roleEntry = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $partialRequest.RoleDefinitionId | Where-Object -FilterScript {$_.DisplayName -eq $RoleDefinition}
                    if ($null -ne $roleEntry)
                    {
                        $request = $partialRequest
                        $RoleDefinitionId = $partialRequest.RoleDefinitionId
                        break
                    }
                }
            }
            else
            {
                $request = $requests[0]
            }
        }

        $schedules = Get-MgBetaRoleManagementDirectoryRoleAssignmentSchedule -Filter "PrincipalId eq '$($request.PrincipalId)'"
        $schedule = $schedules | Where-Object -FilterScript { $_.RoleDefinitionId -eq $RoleDefinitionId }
        if ($null -eq $schedule)
        {
            foreach ($instance in $schedules)
            {
                $roleDefinitionInfo = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $instance.RoleDefinitionId
                if ($null -ne $roleDefinitionInfo -and $RoleDefinitionInfo.DisplayName -eq $RoleDefinition)
                {
                    $schedule = $instance
                    break
                }
            }
        }

        if ($null -eq $schedule -or $null -eq $request)
        {
            if ($null -eq $schedule)
            {
                Write-Verbose -Message "Could not retrieve the schedule for {$($request.PrincipalId)} & RoleDefinitionId {$RoleDefinitionId}"
            }
            if ($null -eq $request)
            {
                Write-Verbose -Message "Could not request the schedule for {$RoleDefinition}"
            }
            return $nullResult
        }

        $ScheduleInfoValue = @{}

        if ($null -ne $schedule.ScheduleInfo.Expiration)
        {
            $expirationValue = @{
                duration = $schedule.ScheduleInfo.Expiration.Duration
                type     = $schedule.ScheduleInfo.Expiration.Type
            }
            if ($null -ne $schedule.ScheduleInfo.Expiration.EndDateTime)
            {
                $expirationValue.Add('endDateTime', $schedule.ScheduleInfo.Expiration.EndDateTime.ToString('yyyy-MM-ddThh:mm:ssZ'))
            }
            $ScheduleInfoValue.Add('expiration', $expirationValue)
        }
        if ($null -ne $schedule.ScheduleInfo.Recurrence)
        {
            if (Test-M365DSCRecurrenceIsConfigured -RecurrenceSettings $schedule.ScheduleInfo.Recurrence)
            {
                $recurrenceValue = @{
                    pattern = @{
                        dayOfMonth     = $schedule.ScheduleInfo.Recurrence.Pattern.dayOfMonth
                        daysOfWeek     = $schedule.ScheduleInfo.Recurrence.Pattern.daysOfWeek
                        firstDayOfWeek = $schedule.ScheduleInfo.Recurrence.Pattern.firstDayOfWeek
                        index          = $schedule.ScheduleInfo.Recurrence.Pattern.index
                        interval       = $schedule.ScheduleInfo.Recurrence.Pattern.interval
                        month          = $schedule.ScheduleInfo.Recurrence.Pattern.month
                        type           = $schedule.ScheduleInfo.Recurrence.Pattern.type
                    }
                    range   = @{
                        endDate             = $schedule.ScheduleInfo.Recurrence.Range.endDate
                        numberOfOccurrences = $schedule.ScheduleInfo.Recurrence.Range.numberOfOccurrences
                        recurrenceTimeZone  = $schedule.ScheduleInfo.Recurrence.Range.recurrenceTimeZone
                        startDate           = $schedule.ScheduleInfo.Recurrence.Range.startDate
                        type                = $schedule.ScheduleInfo.Recurrence.Range.type
                    }
                }
                $ScheduleInfoValue.Add('Recurrence', $recurrenceValue)
            }
        }
        if ($null -ne $schedule.ScheduleInfo.StartDateTime)
        {
            $ScheduleInfoValue.Add('StartDateTime', $schedule.ScheduleInfo.StartDateTime.ToString('yyyy-MM-ddThh:mm:ssZ'))
        }

        $ticketInfoValue = $null
        if ($null -ne $request.TicketInfo)
        {
            $ticketInfoValue = @{
                ticketNumber = $request.TicketInfo.TicketNumber
                ticketSystem = $request.TicketInfo.TicketSystem
            }
        }

        $results = @{
            Principal             = $PrincipalValue
            PrincipalType         = $PrincipalType
            RoleDefinition        = $RoleDefinition
            DirectoryScopeId      = $request.DirectoryScopeId
            AppScopeId            = $request.AppScopeId
            Action                = $request.Action
            Id                    = $request.Id
            Justification         = $request.Justification
            IsValidationOnly      = $request.IsValidationOnly
            ScheduleInfo          = $ScheduleInfoValue
            TicketInfo            = $ticketInfoValue
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
        }
        return $results
    }
    catch
    {
        Write-Verbose "Error: $_"
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
        $Principal,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RoleDefinition,

        [Parameter(Mandatory = $true)]
        [ValidateSet('User', 'Group', 'ServicePrincipal')]
        [System.String]
        $PrincipalType,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DirectoryScopeId,

        [Parameter()]
        [System.String]
        $AppScopeId,

        [Parameter()]
        [ValidateSet('adminAssign', 'adminUpdate', 'adminRemove', 'selfActivate', 'selfDeactivate', 'adminExtend', 'adminRenew', 'selfExtend', 'selfRenew', 'unknownFutureValue')]
        [System.String]
        $Action,

        [Parameter()]
        [System.String]
        $Justification,

        [Parameter()]
        [System.Boolean]
        $IsValidationOnly,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ScheduleInfo,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $TicketInfo,

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
        $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
            -InboundParameters $PSBoundParameters `

    }
    catch
    {
        Write-Verbose -Message $_
    }

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
    $PSBoundParameters.Remove('Verbose') | Out-Null
    $PSBoundParameters.Remove('AccessTokens') | Out-Null

    $ParametersOps = ([Hashtable]$PSBoundParameters).clone()

    if ($PrincipalType -eq 'User')
    {
        [Array]$PrincipalIdValue = (Get-MgUser -Filter "UserPrincipalName eq '$($Principal -replace "'", "''")'").Id
    }
    elseif ($PrincipalType -eq 'Group')
    {
        [Array]$PrincipalIdValue = (Get-MgGroup -Filter "DisplayName eq '$($Principal -replace "'", "''")'").Id
    }
    elseif ($PrincipalType -eq 'ServicePrincipal')
    {
        [Array]$PrincipalIdValue = (Get-MgServicePrincipal -Filter "DisplayName eq '$($Principal -replace "'", "''")'").Id
    }

    if ($null -eq $PrincipalIdValue)
    {
        throw "Couldn't find Principal {$PrincipalId} of type {$PrincipalType}"
    }
    elseif ($PrincipalIdValue.Length -gt 1)
    {
        throw "Multiple Principal with ID {$PrincipalId} of type {$PrincipalType} were found. Cannot create schedule."
    }
    $ParametersOps.Add('PrincipalId', $PrincipalIdValue[0])
    $ParametersOps.Remove('Principal') | Out-Null

    $RoleDefinitionIdValue = (Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($RoleDefinition -replace "'", "''")'").Id
    $ParametersOps.Add('RoleDefinitionId', $RoleDefinitionIdValue)
    $ParametersOps.Remove('RoleDefinition') | Out-Null

    if ($null -ne $ScheduleInfo)
    {
        $ScheduleInfoValue = @{}

        if ($ScheduleInfo.StartDateTime)
        {
            $ScheduleInfoValue.Add('startDateTime', $ScheduleInfo.StartDateTime)
        }

        if ($ScheduleInfo.Expiration)
        {
            $expirationValue = @{
                endDateTime = $ScheduleInfo.Expiration.endDateTime
                type        = $ScheduleInfo.Expiration.type
            }
            if ($ScheduleInfo.Expiration.duration)
            {
                $expirationValue.Add('duration', $ScheduleInfo.Expiration.duration)
            }
            $ScheduleInfoValue.Add('Expiration', $expirationValue)
        }

        if ($ScheduleInfo.Recurrence)
        {
            $Found = $false
            $recurrenceValue = @{}

            if ($ScheduleInfo.Recurrence.Pattern)
            {
                $Found = $true
                $patternValue = @{
                    dayOfMonth     = $ScheduleInfo.Recurrence.Pattern.dayOfMonth
                    daysOfWeek     = $ScheduleInfo.Recurrence.Pattern.daysOfWeek
                    firstDayOfWeek = $ScheduleInfo.Recurrence.Pattern.firstDayOfWeek
                    index          = $ScheduleInfo.Recurrence.Pattern.index
                    interval       = $ScheduleInfo.Recurrence.Pattern.interval
                    month          = $ScheduleInfo.Recurrence.Pattern.month
                    type           = $ScheduleInfo.Recurrence.Pattern.type
                }
                $recurrenceValue.Add('Pattern', $patternValue)
            }
            if ($ScheduleInfo.Recurrence.Range)
            {
                $Found = $true
                $rangeValue = @{
                    endDate             = $ScheduleInfo.Recurrence.Range.endDate
                    numberOfOccurrences = $ScheduleInfo.Recurrence.Range.numberOfOccurrences
                    recurrenceTimeZone  = $ScheduleInfo.Recurrence.Range.recurrenceTimeZone
                    startDate           = $ScheduleInfo.Recurrence.Range.startDate
                    type                = $ScheduleInfo.Recurrence.Range.type
                }
                $recurrenceValue.Add('Range', $rangeValue)
            }
            if ($Found)
            {
                $ScheduleInfoValue.Add('Recurrence', $recurrenceValue)
            }
        }
        Write-Verbose -Message "ScheduleInfo: $(Convert-M365DscHashtableToString -Hashtable $ScheduleInfoValue)"
        $ParametersOps.ScheduleInfo = $ScheduleInfoValue
    }
    $ParametersOps.Remove('PrincipalType') | Out-Null
    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating a Role Assignment Schedule Request for principal {$Principal} and role {$RoleDefinition}"
        $ParametersOps.Remove('Id') | Out-Null
        Write-Verbose -Message "Values: $(Convert-M365DscHashtableToString -Hashtable $ParametersOps)"
        New-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest @ParametersOps
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating the Role Assignment Schedule Request for principal {$Principal} and role {$RoleDefinition}"
        $ParametersOps.Remove('Id') | Out-Null
        $ParametersOps.Action = 'AdminUpdate'
        New-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest @ParametersOps
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing the Role Assignment Schedule Request for principal {$Principal} and role {$RoleDefinition}"
        $ParametersOps.Remove('Id') | Out-Null
        $ParametersOps.Action = 'AdminRemove'
        New-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest @ParametersOps
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
        $Principal,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RoleDefinition,

        [Parameter(Mandatory = $true)]
        [ValidateSet('User', 'Group', 'ServicePrincipal')]
        [System.String]
        $PrincipalType,

        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DirectoryScopeId,

        [Parameter()]
        [System.String]
        $AppScopeId,

        [Parameter()]
        [ValidateSet('adminAssign', 'adminUpdate', 'adminRemove', 'selfActivate', 'selfDeactivate', 'adminExtend', 'adminRenew', 'selfExtend', 'selfRenew', 'unknownFutureValue')]
        [System.String]
        $Action,

        [Parameter()]
        [System.String]
        $Justification,

        [Parameter()]
        [System.Boolean]
        $IsValidationOnly,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $ScheduleInfo,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $TicketInfo,

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

    Write-Verbose -Message "Testing configuration of the Azure AD Role Eligibility Schedule Request for user {$Principal} and role {$RoleDefinition}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $ValuesToCheck.Remove('Action') | Out-Null
    if ($null -ne $CurrentValues.ScheduleInfo -and $null -ne $ValuesToCheck.ScheduleInfo)
    {
        # Compare ScheduleInfo.Expiration
        if ($CurrentValues.ScheduleInfo.Expiration.duration -ne $ValuesToCheck.ScheduleInfo.Expiration.duration -or `
                $CurrentValues.ScheduleInfo.Expiration.endDateTime -ne $ValuesToCheck.ScheduleInfo.Expiration.endDateTime -or `
                $CurrentValues.ScheduleInfo.Expiration.type -ne $ValuesToCheck.ScheduleInfo.Expiration.type)
        {
            Write-Verbose -Message 'Discrepancy found in ScheduleInfo.Expiration'
            Write-Verbose -Message "Current: $($CurrentValues.ScheduleInfo.Expiration | Out-String)"
            Write-Verbose -Message "Desired: $($ValuesToCheck.ScheduleInfo.Expiration | Out-String)"
            return $false
        }

        # Compare ScheduleInfo.Recurrence.Pattern
        if ($CurrentValues.ScheduleInfo.Recurrence.Pattern.dayOfMonth -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.dayOfMonth -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.daysOfWeek -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.daysOfWeek -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.firstDayOfWeek -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.firstDayOfWeek -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.index -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.index -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.interval -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.interval -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.month -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.month -or `
                $CurrentValues.ScheduleInfo.Recurrence.Pattern.type -ne $ValuesToCheck.ScheduleInfo.Recurrence.Pattern.type)
        {
            Write-Verbose -Message 'Discrepancy found in ScheduleInfo.Recurrence.Pattern'
            Write-Verbose -Message "Current: $($CurrentValues.ScheduleInfo.Recurrence.Pattern | Out-String)"
            Write-Verbose -Message "Desired: $($ValuesToCheck.ScheduleInfo.Recurrence.Pattern | Out-String)"
            return $false
        }

        # Compare ScheduleInfo.Recurrence.Range
        if ($CurrentValues.ScheduleInfo.Recurrence.Range.endDate -ne $ValuesToCheck.ScheduleInfo.Recurrence.Range.endDate -or `
                $CurrentValues.ScheduleInfo.Recurrence.Range.numberOfOccurrences -ne $ValuesToCheck.ScheduleInfo.Recurrence.Range.numberOfOccurrences -or `
                $CurrentValues.ScheduleInfo.Recurrence.Range.recurrenceTimeZone -ne $ValuesToCheck.ScheduleInfo.Recurrence.Range.recurrenceTimeZone -or `
                $CurrentValues.ScheduleInfo.Recurrence.Range.startDate -ne $ValuesToCheck.ScheduleInfo.Recurrence.Range.startDate -or `
                $CurrentValues.ScheduleInfo.Recurrence.Range.type -ne $ValuesToCheck.ScheduleInfo.Recurrence.Range.type)
        {
            Write-Verbose -Message 'Discrepancy found in ScheduleInfo.Recurrence.Range'
            Write-Verbose -Message "Current: $($CurrentValues.ScheduleInfo.Recurrence.Range | Out-String)"
            Write-Verbose -Message "Desired: $($ValuesToCheck.ScheduleInfo.Recurrence.Range | Out-String)"
            return $false
        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    $ValuesToCheck.Remove('ScheduleInfo') | Out-Null
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
        #region resource generator code
        $schedules = Get-MgBetaRoleManagementDirectoryRoleAssignmentSchedule -All -ErrorAction Stop
        [array] $Script:exportedInstances = @()
        [array] $allRequests = Get-MgBetaRoleManagementDirectoryRoleAssignmentScheduleRequest -All `
            -Filter "Status ne 'Revoked'" -ErrorAction Stop
        foreach ($schedule in $schedules)
        {
            [array] $Script:exportedInstances += $allRequests | Where-Object -FilterScript { $_.TargetScheduleId -eq $schedule.Id }
        }
        #endregion

        $i = 1
        $dscContent = ''
        if ($Script:exportedInstances.Length -eq 0)
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
        }
        else
        {
            Write-M365DSCHost -Message "`r`n" -DeferWrite
        }
        foreach ($request in $Script:exportedInstances)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = $request.Id
            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $displayedKey" -DeferWrite

            # Find the Principal Type
            $principalType = 'User'
            $userInfo = Get-MgUser -UserId $request.PrincipalId -ErrorAction SilentlyContinue

            if ($null -eq $userInfo)
            {
                $principalType = 'Group'
                $groupInfo = Get-MgGroup -GroupId $request.PrincipalId -ErrorAction SilentlyContinue
                if ($null -eq $groupInfo)
                {
                    $principalType = 'ServicePrincipal'
                    $spnInfo = Get-MgServicePrincipal -ServicePrincipalId $request.PrincipalId
                    $PrincipalValue = $spnInfo.DisplayName
                }
                else
                {
                    $PrincipalValue = $groupInfo.DisplayName
                }
            }
            else
            {
                $PrincipalValue = $userInfo.UserPrincipalName
            }

            $RoleDefinitionId = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $request.RoleDefinitionId
            $params = @{
                Id                    = $request.Id
                Principal             = $PrincipalValue
                PrincipalType         = $principalType
                DirectoryScopeId      = $request.DirectoryScopeId
                RoleDefinition        = $RoleDefinitionId.DisplayName
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

            if ($null -ne $Results.ScheduleInfo)
            {
                $complexMapping = @(
                    @{
                        Name            = 'ScheduleInfo'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestSchedule'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'expiration'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestScheduleExpiration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'recurrence'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestScheduleRecurrence'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'pattern'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestScheduleRecurrencePattern'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'range'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestScheduleRecurrenceRange'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.ScheduleInfo `
                    -CIMInstanceName 'MSFT_AADRoleAssignmentScheduleRequestSchedule' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.ScheduleInfo = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('ScheduleInfo') | Out-Null
                }
            }
            if ($null -ne $Results.TicketInfo)
            {
                $complexMapping = @(
                    @{
                        Name            = 'TicketInfo'
                        CimInstanceName = 'MSFT_AADRoleAssignmentScheduleRequestTicketInfo'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.TicketInfo `
                    -CIMInstanceName 'MSFT_AADRoleAssignmentScheduleRequestTicketInfo' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.TicketInfo = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('TicketInfo') | Out-Null
                }
            }
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('ScheduleInfo', 'TicketInfo')

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
        if ($_.ErrorDetails.Message -like '*The tenant needs an AAD Premium*' -or `
                $_.ErrorDetails.MEssage -like '*[AadPremiumLicenseRequired]*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
        }
        else
        {
            Write-Verbose -Message "Exception: $($_.Exception.Message)"
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

function Test-M365DSCRecurrenceIsConfigured
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $RecurrenceSettings
    )

    if ($null -eq $RecurrenceSettings.Pattern.DayOfMonth -and `
        $null -eq $RecurrenceSettings.Pattern.DayOfWeek -and `
        $null -eq $RecurrenceSettings.Pattern.FirstDayOfWeek -and `
        $null -eq $RecurrenceSettings.Pattern.Index -and `
        $null -eq $RecurrenceSettings.Pattern.Interval -and `
        $null -eq $RecurrenceSettings.Pattern.Month -and `
        $null -eq $RecurrenceSettings.Pattern.Type -and `
        $null -eq $RecurrenceSettings.Range.EndDate -and `
        $null -eq $RecurrenceSettings.Range.NumberOfOccurrences -and `
        $null -eq $RecurrenceSettings.Range.RecurrenceTimeZone -and `
        $null -eq $RecurrenceSettings.Range.StartDate -and `
        $null -eq $RecurrenceSettings.Range.Type)
    {
        return $false
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
