function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $IdentitySources,

        [Parameter()]
        [ValidateSet('configured', 'proposed', 'unknownFutureValue')]
        [System.String]
        $State,

        [Parameter()]
        [String[]]
        $ExternalSponsors,

        [Parameter()]
        [String[]]
        $InternalSponsors,

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
        if (-not $Script:exportedInstance -or $Script:exportedInstance.Id -ne $Id)
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

            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $getValue = Get-MgBetaEntitlementManagementConnectedOrganization -ConnectedOrganizationId $Id `
                    -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                if (-not [System.String]::IsNullOrEmpty($Id))
                {
                    Write-Verbose -Message "Entitlement Management Connected Organization with id {$Id} was not found."
                }

                if (-not [string]::IsNullOrEmpty($DisplayName))
                {
                    $getValue = Get-MgBetaEntitlementManagementConnectedOrganization `
                        -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue
                }
            }
        }
        else
        {
            $getValue = $Script:exportedInstance
        }

        if ($null -eq $getValue)
        {
            Write-Verbose -Message "Entitlement Management Connected Organization with displayName {$DisplayName} was not found."
            return $nullResult
        }

        Write-Verbose -Message "Entitlement Management Connected Organization with id {$($getValue.id)} and displayName {$($getValue.DisplayName)} was found."
        [Array]$getExternalSponsors = Get-MgBetaEntitlementManagementConnectedOrganizationExternalSponsor -ConnectedOrganizationId $getValue.id

        if ($null -ne $getExternalSponsors -and $getExternalSponsors.count -gt 0)
        {
            $sponsors = @()
            foreach ($sponsor in $getExternalSponsors)
            {
                $sponsors += $sponsor.id
            }
            $getExternalSponsors = $sponsors
        }

        [Array]$getInternalSponsors = Get-MgBetaEntitlementManagementConnectedOrganizationInternalSponsor -ConnectedOrganizationId $getValue.id

        if ($null -ne $getInternalSponsors -and $getInternalSponsors.count -gt 0)
        {
            $sponsors = @()
            foreach ($sponsor in $getInternalSponsors)
            {
                $sponsors += $sponsor.id
            }
            $getInternalSponsors = $sponsors
        }

        $getIdentitySources = $null
        if ($null -ne $getValue.IdentitySources)
        {
            $sources = @()
            foreach ($source in $getValue.IdentitySources)
            {
                $formattedSource = @{
                    odataType = $source.AdditionalProperties.'@odata.type'
                }

                if (-not [String]::IsNullOrEmpty($source.AdditionalProperties.displayName))
                {
                    $formattedSource.Add('DisplayName', $source.AdditionalProperties.displayName)
                }

                if (-not [String]::IsNullOrEmpty($source.AdditionalProperties.tenantId))
                {
                    $formattedSource.Add('ExternalTenantId', $source.AdditionalProperties.tenantId)
                }

                if (-not [String]::IsNullOrEmpty($source.AdditionalProperties.cloudInstance))
                {
                    $formattedSource.Add('CloudInstance', $source.AdditionalProperties.cloudInstance)
                }

                if (-not [String]::IsNullOrEmpty($source.AdditionalProperties.domainName))
                {
                    $formattedSource.Add('DomainName', $source.AdditionalProperties.domainName)
                }

                if (-not [String]::IsNullOrEmpty($source.AdditionalProperties.issuerUri))
                {
                    $formattedSource.Add('IssuerUri', $source.AdditionalProperties.issuerUri)
                }
                $sources += $formattedSource
            }
            $getIdentitySources = $sources
        }

        $ObjectGuid = [System.Guid]::empty
        $ExternalSponsorsValues = @()
        foreach ($sponsor in $getExternalSponsors)
        {
            if ([System.Guid]::TryParse($sponsor, [System.Management.Automation.PSReference]$ObjectGuid))
            {
                try
                {
                    $user = Get-MgUser -UserId $sponsor
                    $ExternalSponsorsValues += $user.UserPrincipalName
                }
                catch
                {
                    Write-Verbose -Message "Couldn't find external sponsor with id {$sponsor}"
                }
            }
            else
            {
                $ExternalSponsorsValues += $sponsor
            }
        }

        $InternalSponsorsValues = @()
        foreach ($sponsor in $getInternalSponsors)
        {
            if ([System.Guid]::TryParse($sponsor, [System.Management.Automation.PSReference]$ObjectGuid))
            {
                try
                {
                    $user = Get-MgUser -UserId $sponsor
                    $InternalSponsorsValues += $user.UserPrincipalName
                }
                catch
                {
                    Write-Verbose -Message "Couldn't find inter sponsor with id {$sponsor}"
                }
            }
            else
            {
                $InternalSponsorsValues += $sponsor
            }
        }

        $results = @{
            Id                    = $getValue.id
            Description           = $getValue.description
            DisplayName           = $getValue.displayName
            ExternalSponsors      = $ExternalSponsorsValues
            IdentitySources       = $getIdentitySources
            InternalSponsors      = $InternalSponsorsValues
            State                 = $getValue.state
            Ensure                = 'Present'
            Credential            = $Credential
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            ApplicationSecret     = $ApplicationSecret
            CertificateThumbprint = $CertificateThumbprint
            Managedidentity       = $ManagedIdentity.IsPresent
            AccessTokens          = $AccessTokens
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
        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $IdentitySources,

        [Parameter()]
        [ValidateSet('configured', 'proposed', 'unknownFutureValue')]
        [System.String]
        $State,

        [Parameter()]
        [String[]]
        $ExternalSponsors,

        [Parameter()]
        [String[]]
        $InternalSponsors,

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

    #Import-Module Microsoft.Graph.DirectoryObjects -Force
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

    $keyToRename = @{
        'odataType'        = '@odata.type'
        'ExternalTenantId' = 'tenantId'
    }

    if ($Ensure -eq 'Present')
    {
        $ObjectGuid = [System.Guid]::empty
        $ExternalSponsorsValues = @()
        foreach ($sponsor in $ExternalSponsors)
        {
            if (-not [System.Guid]::TryParse($sponsor, [System.Management.Automation.PSReference]$ObjectGuid))
            {
                try
                {
                    $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                    if ($null -ne $user)
                    {
                        $ExternalSponsorsValues += $user.Id
                    }
                    else
                    {
                        Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                }
            }
            else
            {
                $ExternalSponsorsValues += $sponsor
            }
        }
        $ExternalSponsors = $ExternalSponsorsValues

        $InternalSponsorsValues = @()
        foreach ($sponsor in $InternalSponsors)
        {
            if (-not [System.Guid]::TryParse($sponsor, [System.Management.Automation.PSReference]$ObjectGuid))
            {
                try
                {
                    $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                    if ($null -ne $user)
                    {
                        $InternalSponsorsValues += $user.Id
                    }
                    else
                    {
                        Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                    }
                }
                catch
                {
                    Write-Verbose -Message "Could not find External Sponsor {$sponsor}"
                }
            }
            else
            {
                $InternalSponsorsValues += $sponsor
            }
        }
        $InternalSponsors = $InternalSponsorsValues
    }

    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating a new Entitlement Management Connected Organization {$DisplayName}"

        $CreateParameters = ([Hashtable]$PSBoundParameters).clone()
        $CreateParameters = Rename-M365DSCCimInstanceParameter -Properties $CreateParameters -KeyMapping $keyToRename

        $CreateParameters.Remove('Id') | Out-Null
        $CreateParameters.Remove('ExternalSponsors') | Out-Null
        $CreateParameters.Remove('InternalSponsors') | Out-Null

        $keys = (([Hashtable]$CreateParameters).clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $CreateParameters.$key -and $CreateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $CreateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters.$key
            }
        }
        Write-Verbose -Message "Create Parameters: $(Convert-M365DscHashtableToString -Hashtable $CreateParameters)"
        $TenantIdValue = $CreateParameters.IdentitySources.TenantId
        $url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/tenantRelationships/microsoft.graph.findTenantInformationByTenantId(tenantId='$TenantIdValue')"
        $DomainName = (Invoke-MgGraphRequest -Method 'GET' -Uri $url).defaultDomainName
        $newConnectedOrganization = New-MgBetaEntitlementManagementConnectedOrganization -Description $CreateParameters.Description -DisplayName $CreateParameters.DisplayName -State $CreateParameters.State -DomainName $DomainName

        foreach ($sponsor in $ExternalSponsors)
        {
            $directoryObject = Get-MgBetaDirectoryObject -DirectoryObjectId $sponsor
            $directoryObjectType = $directoryObject.AdditionalProperties.'@odata.type'
            $directoryObjectType = ($directoryObject.AdditionalProperties.'@odata.type').split('.') | Select-Object -Last 1
            $directoryObjectRef = @{
                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/$($directoryObjectType)s/$($sponsor)"
            }

            New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef `
                -ConnectedOrganizationId $newConnectedOrganization.id `
                -BodyParameter $directoryObjectRef
        }

        foreach ($sponsor in $InternalSponsors)
        {
            $directoryObject = Get-MgBetaDirectoryObject -DirectoryObjectId $sponsor
            $directoryObjectType = ($directoryObject.AdditionalProperties.'@odata.type').split('.') | Select-Object -Last 1
            $directoryObjectRef = @{
                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/$($directoryObjectType)s/$($sponsor)"
            }

            New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef `
                -ConnectedOrganizationId $newConnectedOrganization.id `
                -BodyParameter $directoryObjectRef
        }

    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating a new Entitlement Management Connected Organization {$($currentInstance.Id)}"

        $UpdateParameters = ([Hashtable]$PSBoundParameters).clone()
        $UpdateParameters = Rename-M365DSCCimInstanceParameter -Properties $UpdateParameters -KeyMapping $keyToRename

        $UpdateParameters.Remove('Id') | Out-Null
        $UpdateParameters.Remove('ExternalSponsors') | Out-Null
        $UpdateParameters.Remove('InternalSponsors') | Out-Null


        $keys = (([Hashtable]$UpdateParameters).clone()).Keys
        foreach ($key in $keys)
        {
            if ($null -ne $UpdateParameters.$key -and $UpdateParameters.$key.getType().Name -like '*cimInstance*')
            {
                $UpdateParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters.$key
            }
        }

        Update-MgBetaEntitlementManagementConnectedOrganization -BodyParameter $UpdateParameters `
            -ConnectedOrganizationId $currentInstance.Id

        #region External Sponsors
        if ($currentInstance.ExternalSponsors)
        {
            $currentExternalSponsors = @()
            foreach ($sponsor in $CurrentInstance.ExternalSponsors)
            {
                $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                if ($user)
                {
                    $currentExternalSponsors += $user.Id
                }
            }
            $currentInstance.ExternalSponsors = $currentExternalSponsors
        }
        $sponsorsDifferences = Compare-Object -ReferenceObject @($ExternalSponsors | Select-Object) -DifferenceObject @($currentInstance.ExternalSponsors | Select-Object)
        $sponsorsToAdd = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
        $sponsorsToRemove = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }).InputObject
        foreach ($sponsor in $sponsorsToAdd)
        {
            $directoryObject = Get-MgBetaDirectoryObject -DirectoryObjectId $sponsor
            $directoryObjectType = $directoryObject.AdditionalProperties.'@odata.type'
            $directoryObjectType = ($directoryObject.AdditionalProperties.'@odata.type').split('.') | Select-Object -Last 1
            $directoryObjectRef = @{
                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/$($directoryObjectType)s/$($sponsor)"
            }

            New-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorByRef `
                -ConnectedOrganizationId $currentInstance.Id `
                -BodyParameter $directoryObjectRef
        }
        foreach ($sponsor in $sponsorsToRemove)
        {
            Remove-MgBetaEntitlementManagementConnectedOrganizationExternalSponsorDirectoryObjectByRef `
                -ConnectedOrganizationId $currentInstance.Id `
                -DirectoryObjectId $sponsor
        }
        #endregion

        #region Internal Sponsors
        if ($currentInstance.InternalSponsors)
        {
            $currentInternalSponsors = @()
            foreach ($sponsor in $CurrentInstance.InternalSponsors)
            {
                $user = Get-MgUser -UserId $sponsor -ErrorAction SilentlyContinue
                if ($user)
                {
                    $currentInternalSponsors += $user.Id
                }
            }
            $currentInstance.InternalSponsors = $currentInternalSponsors
        }
        $sponsorsDifferences = Compare-Object -ReferenceObject @($InternalSponsors | Select-Object) -DifferenceObject @($currentInstance.InternalSponsors | Select-Object)
        $sponsorsToAdd = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
        $sponsorsToRemove = ($sponsorsDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }).InputObject
        foreach ($sponsor in $sponsorsToAdd)
        {
            $directoryObject = Get-MgBetaDirectoryObject -DirectoryObjectId $sponsor
            $directoryObjectType = $directoryObject.AdditionalProperties.'@odata.type'
            $directoryObjectType = ($directoryObject.AdditionalProperties.'@odata.type').split('.') | Select-Object -Last 1
            $directoryObjectRef = @{
                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/$($directoryObjectType)s/$($sponsor)"
            }

            New-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorByRef `
                -ConnectedOrganizationId $currentInstance.Id `
                -BodyParameter $directoryObjectRef
        }
        foreach ($sponsor in $sponsorsToRemove)
        {
            Remove-MgBetaEntitlementManagementConnectedOrganizationInternalSponsorDirectoryObjectByRef `
                -ConnectedOrganizationId $currentInstance.Id `
                -DirectoryObjectId $sponsor
        }
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing a new Entitlement Management Connected Organization  {$($currentInstance.Id)}"
        Remove-MgBetaEntitlementManagementConnectedOrganization -ConnectedOrganizationId $currentInstance.Id
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
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $IdentitySources,

        [Parameter()]
        [ValidateSet('configured', 'proposed', 'unknownFutureValue')]
        [System.String]
        $State,

        [Parameter()]
        [String[]]
        $ExternalSponsors,

        [Parameter()]
        [String[]]
        $InternalSponsors,

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

    Write-Verbose -Message "Testing configuration of {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $testResult = $true

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
                $testResult = $false
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }
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

        #region resource generator code
        [array]$getValue = Get-MgBetaEntitlementManagementConnectedOrganization `
            -ErrorAction Stop `
            -All
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

            $displayedKey = $config.id
            if (-not [String]::IsNullOrEmpty($config.displayName))
            {
                $displayedKey = $config.displayName
            }
            Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
            $params = @{
                id                    = $config.id
                DisplayName           = $displayedKey
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Script:exportedInstance = $config
            $Results = Get-TargetResource @Params

            if ($Results.IdentitySources)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.IdentitySources -CIMInstanceName AADEntitlementManagementConnectedOrganizationIdentitySource
                if ($complexTypeStringResult)
                {
                    $Results.IdentitySources = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('IdentitySources') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential `
                -NoEscape @('IdentitySources')

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
        if ($_.ErrorDetails.Message -like '*User is not authorized to perform the operation.*')
        {
            Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
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
