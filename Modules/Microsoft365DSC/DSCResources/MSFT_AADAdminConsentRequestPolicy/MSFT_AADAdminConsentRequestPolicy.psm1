function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $IsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyReviewers,

        [Parameter()]
        [System.Boolean]
        $RemindersEnabled,

        [Parameter()]
        [System.UInt32]
        $RequestDurationInDays,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Reviewers,

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
        $instance = Get-MgBetaPolicyAdminConsentRequestPolicy -ErrorAction SilentlyContinue
        if ($null -eq $instance)
        {
            throw 'Could not retrieve the Admin Consent Request Policy'
        }

        $reviewersValue = @()
        foreach ($reviewer in $instance.Reviewers)
        {
            if ($reviewer.Query.Contains('/users/'))
            {
                $userId = $reviewer.Query.Split('/')[3]
                $userInfo = Get-MgUser -UserId $userId

                $entry = @{
                    ReviewerType = 'User'
                    ReviewerId   = $userInfo.UserPrincipalName
                }
            }
            elseif ($reviewer.Query.Contains('/groups/'))
            {
                $groupId = $reviewer.Query.Split('/')[3]
                try
                {
                    $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction SilentlyContinue
                    $entry = @{
                        ReviewerType = 'Group'
                        ReviewerId   = $groupInfo.DisplayName
                    }
                }
                catch
                {
                    $message = "Group with ID $groupId specified in Reviewers not found"
                    New-M365DSCLogEntry -Message $message `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                    continue
                }
            }
            elseif ($reviewer.Query.Contains('directory/roleAssignments?$'))
            {
                $roleId = $reviewer.Query.Replace("/beta/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq ", '').Replace("'", '')
                $roleInfo = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $roleId
                $entry = @{
                    ReviewerType = 'Role'
                    ReviewerId   = $roleInfo.DisplayName
                }
            }
            $reviewersValue += $entry
        }

        $results = @{
            IsSingleInstance      = 'Yes'
            IsEnabled             = $instance.IsEnabled
            NotifyReviewers       = $instance.NotifyReviewers
            RemindersEnabled      = $instance.RemindersEnabled
            RequestDurationInDays = $instance.RequestDurationInDays
            Reviewers             = $reviewersValue
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            ManagedIdentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
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
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $IsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyReviewers,

        [Parameter()]
        [System.Boolean]
        $RemindersEnabled,

        [Parameter()]
        [System.UInt32]
        $RequestDurationInDays,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Reviewers,

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

    $reviewerValues = @()
    foreach ($reviewer in $Reviewers)
    {
        if ($reviewer.ReviewerType -eq 'User')
        {
            $userInfo = Get-MgUser -Filter "UserPrincipalName eq '$($reviewer.ReviewerId)'"
            $entry = @{
                query     = "/users/$($userInfo.Id)"
                queryType = 'MicrosoftGraph'
            }
            $reviewerValues += $entry
        }
        elseif ($reviewer.ReviewerType -eq 'Group')
        {
            $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($reviewer.ReviewerId -replace '"', "''")'"
            $entry = @{
                query     = "/groups/$($groupInfo.Id)/transitiveMembers/microsoft.graph.user"
                queryType = 'MicrosoftGraph'
            }
            $reviewerValues += $entry
        }
        elseif ($reviewer.ReviewerType -eq 'Role')
        {
            $roleInfo = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($reviewer.ReviewerId -replace '"', "''")'"
            $entry = @{
                query     = "/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '$($roleInfo.Id.Replace('\u0027', ''))'"
                queryType = 'MicrosoftGraph'
            }
            $reviewerValues += $entry
        }
    }

    $updateParameters = @{
        isEnabled             = $IsEnabled
        reviewers             = $reviewerValues
        notifyReviewers       = $NotifyReviewers
        remindersEnabled      = $RemindersEnabled
        requestDurationInDays = $RequestDurationInDays
    }

    $updateJSON = ConvertTo-Json $updateParameters
    Write-Verbose -Message "Updating the Entra Id Admin Consent Request Policy with values: $updateJSON"
    $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'beta/policies/adminConsentRequestPolicy'
    Invoke-MgGraphRequest -Method 'PUT' `
        -Uri $Uri `
        -Body $updateJSON | Out-Null
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.Boolean]
        $IsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyReviewers,

        [Parameter()]
        [System.Boolean]
        $RemindersEnabled,

        [Parameter()]
        [System.UInt32]
        $RequestDurationInDays,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Reviewers,

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

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()
    $testTargetResource = $true

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"
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
                 Write-Verbose "TestResult returned False for $source"
                 $testTargetResource = $false
             }
             else
             {
                 $ValuesToCheck.Remove($key) | Out-Null
             }
         }
    }

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
        [array] $Script:exportedInstances = Get-MgBetaPolicyAdminConsentRequestPolicy -ErrorAction Stop

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
        foreach ($config in $Script:exportedInstances)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $displayedKey = 'Policy'
            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $displayedKey" -DeferWrite
            $params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                ManagedIdentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $config
            $Results = Get-TargetResource @Params
            if ($null -ne $Results.Reviewers)
            {
                $complexMapping = @(
                    @{
                        Name            = 'Reviewers'
                        CimInstanceName = 'AADAdminConsentRequestPolicyReviewer'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.Reviewers `
                    -CIMInstanceName 'AADAdminConsentRequestPolicyReviewer' `
                    -ComplexTypeMapping $complexMapping

                if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.Reviewers = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('Reviewers') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('Reviewers')
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
