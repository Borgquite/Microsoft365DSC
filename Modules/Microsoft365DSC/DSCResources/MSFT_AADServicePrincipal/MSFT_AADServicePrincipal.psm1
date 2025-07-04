function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AppId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoleAssignedTo,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $AlternativeNames,

        [Parameter()]
        [System.Boolean]
        $AccountEnabled,

        [Parameter()]
        [System.Boolean]
        $AppRoleAssignmentRequired,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $CustomSecurityAttributes,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DelegatedPermissionClassifications,

        [Parameter()]
        [System.String]
        $ErrorUrl,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String]
        $LogoutUrl,

        [Parameter()]
        [System.String]
        $Notes,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [System.String]
        $PreferredSingleSignOnMode,

        [Parameter()]
        [System.String]
        $PublisherName,

        [Parameter()]
        [System.String[]]
        $ReplyUrls,

        [Parameter()]
        [System.String]
        $SamlMetadataURL,

        [Parameter()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.String]
        $ServicePrincipalType,

        [Parameter()]
        [System.String[]]
        $Tags,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

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

    try
    {
        if (-not $Script:exportedInstance -or $Script:exportedInstance.AppId -ne $AppId)
        {
            Write-Verbose -Message 'Getting configuration of Azure AD ServicePrincipal'
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

            $nullReturn = $PSBoundParameters
            $nullReturn.Ensure = 'Absent'

            try
            {
                if (-not [System.String]::IsNullOrEmpty($ObjectID))
                {
                    $AADServicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $ObjectId `
                        -Expand 'AppRoleAssignedTo' `
                        -ErrorAction Stop
                }
            }
            catch
            {
                Write-Verbose -Message "Azure AD ServicePrincipal with ObjectID: $($ObjectID) could not be retrieved"
            }

            if ($null -eq $AADServicePrincipal)
            {
                $ObjectGuid = [System.Guid]::empty
                if (-not [System.Guid]::TryParse($AppId, [System.Management.Automation.PSReference]$ObjectGuid))
                {
                    $appInstance = Get-MgApplication -Filter "DisplayName eq '$($AppId -replace "'", "''")'"
                    if ($appInstance)
                    {
                        $AADServicePrincipal = Get-MgServicePrincipal -Filter "AppID eq '$($appInstance.AppId)'"
                    }
                }
                else
                {
                    $AADServicePrincipal = Get-MgServicePrincipal -Filter "AppID eq '$($AppId)'"
                }
            }
            if ($null -eq $AADServicePrincipal)
            {
                return $nullReturn
            }
        }
        else
        {
            $AADServicePrincipal = $Script:exportedInstance
        }

        $AppRoleAssignedToValues = @()
        $assignmentsValue = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $AADServicePrincipal.Id -All -ErrorAction SilentlyContinue
        foreach ($principal in $assignmentsValue)
        {
            $currentAssignment = @{
                PrincipalType = $null
                Identity      = $null
            }
            if ($principal.PrincipalType -eq 'User')
            {
                $user = Get-MgUser -UserId $principal.PrincipalId
                $currentAssignment.PrincipalType = 'User'
                $currentAssignment.Identity = $user.UserPrincipalName
                $AppRoleAssignedToValues += $currentAssignment
            }
            elseif ($principal.PrincipalType -eq 'Group')
            {
                $group = Get-MgGroup -GroupId $principal.PrincipalId
                $currentAssignment.PrincipalType = 'Group'
                $currentAssignment.Identity = $group.DisplayName
                $AppRoleAssignedToValues += $currentAssignment
            }
        }

        $ownersValues = @()
        $ownersInfo = Get-MgServicePrincipalOwner -ServicePrincipalId $AADServicePrincipal.Id -ErrorAction SilentlyContinue
        foreach ($ownerInfo in $ownersInfo)
        {
            $info = Get-MgUser -UserId $ownerInfo.Id -ErrorAction SilentlyContinue
            if ($null -ne $info)
            {
                $ownersValues += $info.UserPrincipalName
            }
        }

        [Array]$complexDelegatedPermissionClassifications = @()
        #Managed Identities in AzureGov return exception when pulling delegatedPermissionClassifications
        try
        {
            $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/servicePrincipals/$($AADServicePrincipal.Id)/delegatedPermissionClassifications"
            $permissionClassifications = Invoke-MgGraphRequest -Uri $Uri -Method Get
        }
        catch
        {
            Write-Verbose -Message "Service Principal didn't return delegated permission classifications. Expected for Managedidentities."
        }

        foreach ($permissionClassification in $permissionClassifications.Value)
        {
            $hashtable = @{
                classification = $permissionClassification.Classification
                permissionName = $permissionClassification.permissionName
            }
            $complexDelegatedPermissionClassifications += $hashtable
        }

        $complexKeyCredentials = @()
        foreach ($currentkeyCredentials in $AADServicePrincipal.keyCredentials)
        {
            $mykeyCredentials = @{}
            if ($null -ne $currentkeyCredentials.customKeyIdentifier)
            {
                $mykeyCredentials.Add('CustomKeyIdentifier', [convert]::ToBase64String($currentkeyCredentials.customKeyIdentifier))
            }
            $mykeyCredentials.Add('DisplayName', $currentkeyCredentials.displayName)
            if ($null -ne $currentkeyCredentials.endDateTime)
            {
                $mykeyCredentials.Add('EndDateTime', ([DateTimeOffset]$currentkeyCredentials.endDateTime).ToString('o'))
            }
            $mykeyCredentials.Add('KeyId', $currentkeyCredentials.keyId)


            if ($null -ne $currentkeyCredentials.Key)
            {
                $mykeyCredentials.Add('Key', [convert]::ToBase64String($currentkeyCredentials.key))
            }

            if ($null -ne $currentkeyCredentials.startDateTime)
            {
                $mykeyCredentials.Add('StartDateTime', ([DateTimeOffset]$currentkeyCredentials.startDateTime).ToString('o'))
            }
            $mykeyCredentials.Add('Type', $currentkeyCredentials.type)
            $mykeyCredentials.Add('Usage', $currentkeyCredentials.usage)
            if ($mykeyCredentials.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexKeyCredentials += $mykeyCredentials
            }
        }

        $complexPasswordCredentials = @()
        foreach ($currentpasswordCredentials in $AADServicePrincipal.passwordCredentials)
        {
            $mypasswordCredentials = @{}
            $mypasswordCredentials.Add('DisplayName', $currentpasswordCredentials.displayName)
            if ($null -ne $currentpasswordCredentials.endDateTime)
            {
                $mypasswordCredentials.Add('EndDateTime', ([DateTimeOffset]$currentpasswordCredentials.endDateTime).ToString('o'))
            }
            $mypasswordCredentials.Add('Hint', $currentpasswordCredentials.hint)
            $mypasswordCredentials.Add('KeyId', $currentpasswordCredentials.keyId)
            if ($null -ne $currentpasswordCredentials.startDateTime)
            {
                $mypasswordCredentials.Add('StartDateTime', ([DateTimeOffset]$currentpasswordCredentials.startDateTime).ToString('o'))
            }
            if ($mypasswordCredentials.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexPasswordCredentials += $mypasswordCredentials
            }
        }

        $complexCustomSecurityAttributes = [Array](Get-CustomSecurityAttributes -ServicePrincipalId $AADServicePrincipal.Id)
        if ($null -eq $complexCustomSecurityAttributes)
        {
            $complexCustomSecurityAttributes = @()
        }

        $result = @{
            AppId                              = $AADServicePrincipal.AppDisplayName
            AppRoleAssignedTo                  = $AppRoleAssignedToValues
            ObjectID                           = $AADServicePrincipal.Id
            DisplayName                        = $AADServicePrincipal.DisplayName
            AlternativeNames                   = $AADServicePrincipal.AlternativeNames
            AccountEnabled                     = [boolean]$AADServicePrincipal.AccountEnabled
            AppRoleAssignmentRequired          = $AADServicePrincipal.AppRoleAssignmentRequired
            CustomSecurityAttributes           = $complexCustomSecurityAttributes
            DelegatedPermissionClassifications = [Array]$complexDelegatedPermissionClassifications
            ErrorUrl                           = $AADServicePrincipal.ErrorUrl
            Homepage                           = $AADServicePrincipal.Homepage
            LogoutUrl                          = $AADServicePrincipal.LogoutUrl
            Notes                              = $AADServicePrincipal.Notes
            Owners                             = $ownersValues
            PreferredSingleSignOnMode          = $AADServicePrincipal.PreferredSingleSignOnMode
            PublisherName                      = $AADServicePrincipal.PublisherName
            ReplyURLs                          = $AADServicePrincipal.ReplyURLs
            SamlMetadataURL                    = $AADServicePrincipal.SamlMetadataURL
            ServicePrincipalNames              = $AADServicePrincipal.ServicePrincipalNames
            ServicePrincipalType               = $AADServicePrincipal.ServicePrincipalType
            Tags                               = $AADServicePrincipal.Tags
            KeyCredentials                     = $complexKeyCredentials
            PasswordCredentials                = $complexPasswordCredentials
            Ensure                             = 'Present'
            Credential                         = $Credential
            ApplicationId                      = $ApplicationId
            ApplicationSecret                  = $ApplicationSecret
            TenantId                           = $TenantId
            CertificateThumbprint              = $CertificateThumbprint
            Managedidentity                    = $ManagedIdentity.IsPresent
            AccessTokens                       = $AccessTokens
        }
        Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
        return $result
    }
    catch
    {
        Write-Verbose -Message $_
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
        $AppId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoleAssignedTo,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $AlternativeNames,

        [Parameter()]
        [System.Boolean]
        $AccountEnabled,

        [Parameter()]
        [System.Boolean]
        $AppRoleAssignmentRequired,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $CustomSecurityAttributes,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DelegatedPermissionClassifications,

        [Parameter()]
        [System.String]
        $ErrorUrl,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String]
        $LogoutUrl,

        [Parameter()]
        [System.String]
        $Notes,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [System.String]
        $PreferredSingleSignOnMode,

        [Parameter()]
        [System.String]
        $PublisherName,

        [Parameter()]
        [System.String[]]
        $ReplyUrls,

        [Parameter()]
        [System.String]
        $SamlMetadataURL,

        [Parameter()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.String]
        $ServicePrincipalType,

        [Parameter()]
        [System.String[]]
        $Tags,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

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

    Write-Verbose -Message 'Setting configuration of Azure AD ServicePrincipal'
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

    $currentAADServicePrincipal = Get-TargetResource @PSBoundParameters
    $currentParameters = $PSBoundParameters
    $currentParameters.Remove('ApplicationId') | Out-Null
    $currentParameters.Remove('TenantId') | Out-Null
    $currentParameters.Remove('CertificateThumbprint') | Out-Null
    $currentParameters.Remove('ManagedIdentity') | Out-Null
    $currentParameters.Remove('Credential') | Out-Null
    $currentParameters.Remove('Ensure') | Out-Null
    $currentParameters.Remove('ObjectID') | Out-Null
    $currentParameters.Remove('ApplicationSecret') | Out-Null
    $currentParameters.Remove('AccessTokens') | Out-Null
    $currentParameters.Remove('Owners') | Out-Null

    # update the custom security attributes to be cmdlet comsumable
    if ($null -ne $currentParameters.CustomSecurityAttributes -and $currentParameters.CustomSecurityAttributes -gt 0)
    {
        $currentParameters.CustomSecurityAttributes = Get-M365DSCAADServicePrincipalCustomSecurityAttributesAsCmdletHashtable -CustomSecurityAttributes $currentParameters.CustomSecurityAttributes
    }
    else
    {
        $currentParameters.Remove('CustomSecurityAttributes')
    }

    # If the AppId was passed as a display name (not in GUID format), translate it to an ID.
    $ObjectGuid = [System.Guid]::empty
    if (-not [System.Guid]::TryParse($AppId, [System.Management.Automation.PSReference]$ObjectGuid))
    {
        Write-Verbose -Message "AppId was provided as a DisplayName. Translating it to an a GUID."
        $appInstance = Get-MgApplication -Filter "DisplayName eq '$($AppId -replace "'", "''")'"
        $currentParameters.AppId = $appInstance.AppId
        Write-Verbose -Message "Translated to AppId {$($currentParameters.AppId)}"
    }

    $AppRoleAssignedToSpecified = $currentParameters.ContainsKey('AppRoleAssignedTo')
    # ServicePrincipal should exist but it doesn't
    if ($Ensure -eq 'Present' -and $currentAADServicePrincipal.Ensure -eq 'Absent')
    {
        # removing Delegated permission classifications from this new call, as adding below separately
        $currentParameters.Remove('DelegatedPermissionClassifications') | Out-Null
        $currentParameters.Remove('AppRoleAssignedTo') | Out-Null

        Write-Verbose -Message 'Creating new Service Principal'
        Write-Verbose -Message "With Values: $(Convert-M365DscHashtableToString -Hashtable $currentParameters)"
        $newSP = New-MgServicePrincipal @currentParameters

        # Assign Owners
        foreach ($owner in $Owners)
        {
            $userInfo = Get-MgUser -UserId $owner
            $body = @{
                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($userInfo.Id)"
            }
            Write-Verbose -Message "Adding new owner {$owner}"
            $newOwner = New-MgServicePrincipalOwnerByRef -ServicePrincipalId $newSP.Id -BodyParameter $body
        }

        # Adding delegated permissions classifications
        if ($null -ne $DelegatedPermissionClassifications)
        {
            foreach ($permissionClassification in $DelegatedPermissionClassifications)
            {
                $params = @{
                    classification = $permissionClassification.Classification
                    permissionName = $permissionClassification.permissionName
                }
                $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/servicePrincipals(appId='$($currentParameters.AppId)')/delegatedPermissionClassifications"
                Invoke-MgGraphRequest -Uri $Uri -Method Post -Body $params
            }
        }

        # Update AppRoleAssignedTo
        if ($AppRoleAssignedToSpecified)
        {
            Write-Verbose -Message "Updating AppRoleAssignedTo value"
            foreach ($assignment in $AppRoleAssignedTo)
            {
                $AppRoleAssignedToValues += @{
                    PrincipalType = $assignment.PrincipalType
                    Identity      = $assignment.Identity
                }

                if ($assignment.PrincipalType -eq 'User')
                {
                    Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                    $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                    $PrincipalIdValue = $user.Id
                }
                else
                {
                    Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                    $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                    $PrincipalIdValue = $group.Id
                }
                $bodyParam = @{
                    principalId = $PrincipalIdValue
                    resourceId  = $newSP.Id
                    appRoleId   = '00000000-0000-0000-0000-000000000000'
                }
                Write-Verbose -Message "Adding Service Principal AppRoleAssignedTo with values:`r`n$(ConvertTo-Json $bodyParam -Depth 3)"
                New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $newSP.Id `
                    -BodyParameter $bodyParam | Out-Null
            }
        }
    }
    # ServicePrincipal should exist and will be configured to desired state
    elseif ($Ensure -eq 'Present' -and $currentAADServicePrincipal.Ensure -eq 'Present')
    {
        Write-Verbose -Message 'Updating existing Service Principal'
        Write-Verbose -Message "CurrentParameters: $($currentParameters | Out-String)"
        Write-Verbose -Message "ServicePrincipalID: $($currentAADServicePrincipal.ObjectID)"
        $AppRoleAssignedToSpecified = $currentParameters.ContainsKey('AppRoleAssignedTo')
        $currentParameters.Remove('AppRoleAssignedTo') | Out-Null
        $currentParameters.Remove('DelegatedPermissionClassifications') | Out-Null

        if ($PreferredSingleSignOnMode -eq 'saml')
        {
            $IdentifierUris = $ServicePrincipalNames | Where-Object { $_ -notmatch $AppId }
            $currentParameters.Remove('ServicePrincipalNames')
        }

        #removing the current custom security attributes
        if ($currentAADServicePrincipal.CustomSecurityAttributes.Count -gt 0)
        {
            $currentAADServicePrincipal.CustomSecurityAttributes = Get-M365DSCAADServicePrincipalCustomSecurityAttributesAsCmdletHashtable -CustomSecurityAttributes $currentAADServicePrincipal.CustomSecurityAttributes -GetForDelete $true
            $CSAParams = @{
                customSecurityAttributes = $currentAADServicePrincipal.CustomSecurityAttributes
            }
            Invoke-MgGraphRequest -Uri ((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/servicePrincipals(appId='$($currentParameters.AppId)')") -Method Patch -Body $CSAParams
        }

        Update-MgServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID @currentParameters

        if ($IdentifierUris)
        {
            Write-Verbose -Message 'Updating the Application ID Uri on the application instance.'
            $appInstance = Get-MgApplication -Filter "AppId eq '$AppId'"
            Update-MgApplication -ApplicationId $appInstance.Id -IdentifierUris $IdentifierUris
        }
        if ($AppRoleAssignedToSpecified)
        {
            Write-Verbose -Message "Need to update AppRoleAssignedTo value"
            [Array]$currentPrincipals = $currentAADServicePrincipal.AppRoleAssignedTo.Identity
            [Array]$desiredPrincipals = $AppRoleAssignedTo.Identity

            if ($null -eq $currentPrincipals)
            {
                $currentPrincipals = @()
            }
            if ($null -eq $desiredPrincipals)
            {
                $desiredPrincipals = @()
            }

            [Array]$differences = Compare-Object -ReferenceObject $currentPrincipals -DifferenceObject $desiredPrincipals
            [Array]$membersToAdd = $differences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }
            [Array]$membersToRemove = $differences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }

            if ($differences.Count -gt 0)
            {
                if ($membersToAdd.Count -gt 0)
                {
                    $AppRoleAssignedToValues = @()
                    foreach ($assignment in $AppRoleAssignedTo)
                    {
                        $AppRoleAssignedToValues += @{
                            PrincipalType = $assignment.PrincipalType
                            Identity      = $assignment.Identity
                        }
                    }
                    foreach ($member in $membersToAdd)
                    {
                        $assignment = $AppRoleAssignedToValues | Where-Object -FilterScript { $_.Identity -eq $member.InputObject }
                        if ($assignment.PrincipalType -eq 'User')
                        {
                            Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                            $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                            $PrincipalIdValue = $user.Id
                        }
                        else
                        {
                            Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                            $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                            $PrincipalIdValue = $group.Id
                        }

                        $bodyParam = @{
                            principalId = $PrincipalIdValue
                            resourceId  = $currentAADServicePrincipal.ObjectID
                            appRoleId   = '00000000-0000-0000-0000-000000000000'
                        }
                        Write-Verbose -Message "Adding member {$($member.InputObject.ToString())}"
                        New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                            -BodyParameter $bodyParam | Out-Null
                    }
                }

                if ($membersToRemove.Count -gt 0)
                {
                    $AppRoleAssignedToValues = @()
                    foreach ($assignment in $currentAADServicePrincipal.AppRoleAssignedTo)
                    {
                        $AppRoleAssignedToValues += @{
                            PrincipalType = $assignment.PrincipalType
                            Identity      = $assignment.Identity
                        }
                    }
                    foreach ($member in $membersToRemove)
                    {
                        $assignment = $AppRoleAssignedToValues | Where-Object -FilterScript { $_.Identity -eq $member.InputObject }
                        if ($assignment.PrincipalType -eq 'User')
                        {
                            Write-Verbose -Message "Retrieving user {$($assignment.Identity)}"
                            $user = Get-MgUser -Filter "startswith(UserPrincipalName, '$($assignment.Identity)')"
                            $PrincipalIdValue = $user.Id
                        }
                        else
                        {
                            Write-Verbose -Message "Retrieving group {$($assignment.Identity)}"
                            $group = Get-MgGroup -Filter "DisplayName eq '$($assignment.Identity -replace "'", "''")'"
                            $PrincipalIdValue = $group.Id
                        }
                        Write-Verbose -Message "PrincipalID Value = '$PrincipalIdValue'"
                        Write-Verbose -Message "ServicePrincipalId = '$($currentAADServicePrincipal.ObjectID)'"
                        $allAssignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID -All
                        $assignmentToRemove = $allAssignments | Where-Object -FilterScript { $_.PrincipalId -eq $PrincipalIdValue }
                        Write-Verbose -Message "Removing member {$($member.InputObject.ToString())}"
                        Remove-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $currentAADServicePrincipal.ObjectID `
                            -AppRoleAssignmentId $assignmentToRemove.Id | Out-Null
                    }
                }
            }
        }

        Write-Verbose -Message 'Checking if owners need to be updated...'

        if ($null -ne $Owners)
        {
            $diffOwners = Compare-Object -ReferenceObject $currentAADServicePrincipal.Owners -DifferenceObject $Owners
        }
        foreach ($diff in $diffOwners)
        {
            $userInfo = Get-MgUser -UserId $diff.InputObject
            if ($diff.SideIndicator -eq '=>')
            {
                $body = @{
                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($userInfo.Id)"
                }
                Write-Verbose -Message "Adding owner {$($userInfo.Id)}"
                New-MgServicePrincipalOwnerByRef -ServicePrincipalId $currentAADServicePrincipal.ObjectId `
                    -BodyParameter $body | Out-Null
            }
            else
            {
                Write-Verbose -Message "Removing owner {$($userInfo.Id)}"
                Remove-MgServicePrincipalOwnerByRef -ServicePrincipalId $currentAADServicePrincipal.ObjectId `
                    -DirectoryObjectId $userInfo.Id | Out-Null
            }
        }

        Write-Verbose -Message 'Checking if DelegatedPermissionClassifications need to be updated...'

        if ($null -ne $DelegatedPermissionClassifications)
        {
            # removing old perm classifications
            $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/servicePrincipals(appId='$($currentParameters.AppId)')/delegatedPermissionClassifications"
            $permissionClassificationList = Invoke-MgGraphRequest -Uri $Uri -Method Get
            foreach ($permissionClassification in $permissionClassificationList.Value)
            {
                Invoke-MgGraphRequest -Uri "$($Uri)/$($permissionClassification.Id)" -Method Delete
            }

            # adding new perm classifications
            foreach ($permissionClassification in $DelegatedPermissionClassifications)
            {
                $params = @{
                    classification = $permissionClassification.Classification
                    permissionName = $permissionClassification.permissionName
                }
                Invoke-MgGraphRequest -Uri $Uri -Method Post -Body $params
            }
        }
    }
    # ServicePrincipal exists but should not
    elseif ($Ensure -eq 'Absent' -and $currentAADServicePrincipal.Ensure -eq 'Present')
    {
        Write-Verbose -Message 'Removing Service Principal'
        Remove-MgServicePrincipal -ServicePrincipalId $currentAADServicePrincipal.ObjectID
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
        $AppId,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoleAssignedTo,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String[]]
        $AlternativeNames,

        [Parameter()]
        [System.Boolean]
        $AccountEnabled,

        [Parameter()]
        [System.Boolean]
        $AppRoleAssignmentRequired,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $CustomSecurityAttributes,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $DelegatedPermissionClassifications,

        [Parameter()]
        [System.String]
        $ErrorUrl,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String]
        $LogoutUrl,

        [Parameter()]
        [System.String]
        $Notes,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [System.String]
        $PreferredSingleSignOnMode,

        [Parameter()]
        [System.String]
        $PublisherName,

        [Parameter()]
        [System.String[]]
        $ReplyUrls,

        [Parameter()]
        [System.String]
        $SamlMetadataURL,

        [Parameter()]
        [System.String[]]
        $ServicePrincipalNames,

        [Parameter()]
        [System.String]
        $ServicePrincipalType,

        [Parameter()]
        [System.String[]]
        $Tags,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

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
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message 'Testing configuration of Azure AD ServicePrincipal'

    $testTargetResource = $true
    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).Clone()

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
                $testTargetResource = $false
            }
            else
            {
                $ValuesToCheck.Remove($key) | Out-Null
            }
        }
    }

    # Evaluate AppId in GUID or DisplayName form.
    $ObjectGuid = [System.Guid]::empty
    if ([System.Guid]::TryParse($ValuesToCheck.AppId, [System.Management.Automation.PSReference]$ObjectGuid))
    {
        # AppId was provided as a GUID, but Get-TargetResource returns it as Display name.
        # Evaluate the translation to display name
        Write-Verbose -Message "AppId was provided as a GUID, translating into a DisplayName"
        $appInstance = Get-MgApplication -Filter "AppId eq '$($ValuesToCheck.AppId)'" -ErrorAction SilentlyContinue
        if ($null -ne $appInstance)
        {
            $ValuesToCheck.AppId = $appInstance.DisplayName
        }
        else
        {
            $spn = Get-MgServicePrincipal -Filter "AppId eq '$($ValuesToCheck.AppId)'"
            $ValuesToCheck.AppId = $spn.DisplayName
        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $ValuesToCheck `
        -ValuesToCheck $ValuesToCheck.Keys `
        -IncludedDrifts $driftedParams

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

    $dscContent = [System.Text.StringBuilder]::new()
    try
    {
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        $Script:ExportMode = $true
        [array] $Script:exportedInstances = Get-MgServicePrincipal -All:$true `
            -Filter $Filter `
            -Expand 'AppRoleAssignedTo' `
            -ErrorAction Stop
        foreach ($AADServicePrincipal in $Script:exportedInstances)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $($AADServicePrincipal.DisplayName)" -DeferWrite
            $Params = @{
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                ApplicationSecret     = $ApplicationSecret
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AppID                 = $AADServicePrincipal.AppId
                AccessTokens          = $AccessTokens
            }
            $Script:exportedInstance = $AADServicePrincipal
            $Results = Get-TargetResource @Params
            if ($Results.Ensure -eq 'Present')
            {
                if ($Results.AppRoleAssignedTo.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AppRoleAssignedTo `
                        -CIMInstanceName 'AADServicePrincipalRoleAssignment'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AppRoleAssignedTo = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AppRoleAssignedTo') | Out-Null
                    }
                }
                if ($Results.DelegatedPermissionClassifications.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DelegatedPermissionClassifications `
                        -CIMInstanceName 'AADServicePrincipalDelegatedPermissionClassification' -IsArray:$true
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DelegatedPermissionClassifications = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DelegatedPermissionClassifications') | Out-Null
                    }
                }
                if ($null -ne $Results.KeyCredentials)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.KeyCredentials `
                        -CIMInstanceName 'MicrosoftGraphkeyCredential' -IsArray:$true
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.KeyCredentials = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KeyCredentials') | Out-Null
                    }
                }
                if ($null -ne $Results.PasswordCredentials)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PasswordCredentials `
                        -CIMInstanceName 'MicrosoftGraphpasswordCredential' -IsArray:$true
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PasswordCredentials = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PasswordCredentials') | Out-Null
                    }
                }
                if ($Results.CustomSecurityAttributes.Count -gt 0)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'CustomSecurityAttributes'
                            CimInstanceName = 'AADServicePrincipalAttributeSet'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'AttributeValues'
                            CimInstanceName = 'AADServicePrincipalAttributeValue'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomSecurityAttributes `
                        -CIMInstanceName 'AADServicePrincipalAttributeSet' `
                        -ComplexTypeMapping $complexMapping `
                        -IsArray:$true
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CustomSecurityAttributes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomSecurityAttributes') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $PSScriptRoot `
                    -Results $Results `
                    -Credential $Credential `
                    -NoEscape @('AppRoleAssignedTo', 'DelegatedPermissionClassifications', 'KeyCredentials', 'PasswordCredentials', 'CustomSecurityAttributes')

                $dscContent.Append($currentDSCBlock) | Out-Null
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
        }
        return $dscContent.ToString()
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

function Get-M365DSCAADServicePrincipalCustomSecurityAttributesAsCmdletHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]
        $CustomSecurityAttributes,

        [Parameter()]
        [System.Boolean]
        $GetForDelete = $false
    )

    # logic to update the custom security attributes to be cmdlet comsumable
    $updatedCustomSecurityAttributes = @{}
    foreach ($attributeSet in $CustomSecurityAttributes)
    {
        $attributeSetKey = $attributeSet.AttributeSetName

        $valuesHashtable = @{}
        $valuesHashtable.Add('@odata.type', '#Microsoft.DirectoryServices.CustomSecurityAttributeValue')
        foreach ($attribute in $attributeSet.AttributeValues)
        {
            $attributeKey = $attribute.AttributeName
            # supply attributeName = $null in the body, if you want to delete this attribute
            if ($GetForDelete -eq $true)
            {
                $valuesHashtable.Add($attributeKey, $null)
                continue
            }

            $odataKey = $attributeKey + '@odata.type'

            if ($null -ne $attribute.StringArrayValue)
            {
                $valuesHashtable.Add($odataKey, '#Collection(String)')
                $attributeValue = $attribute.StringArrayValue
            }
            elseif ($null -ne $attribute.IntArrayValue)
            {
                $valuesHashtable.Add($odataKey, '#Collection(Int32)')
                $attributeValue = $attribute.IntArrayValue
            }
            elseif ($null -ne $attribute.StringValue)
            {
                $valuesHashtable.Add($odataKey, '#String')
                $attributeValue = $attribute.StringValue
            }
            elseif ($null -ne $attribute.IntValue)
            {
                $valuesHashtable.Add($odataKey, '#Int32')
                $attributeValue = $attribute.IntValue
            }
            elseif ($null -ne $attribute.BoolValue)
            {
                $attributeValue = $attribute.BoolValue
            }

            $valuesHashtable.Add($attributeKey, $attributeValue)
        }
        $updatedCustomSecurityAttributes.Add($attributeSetKey, $valuesHashtable)
    }
    return $updatedCustomSecurityAttributes
}

# Function to create MSFT_AttributeValue
function Create-AttributeValue
{
    param (
        [string]$AttributeName,
        [object]$Value
    )

    $attributeValue = @{
        AttributeName    = $AttributeName
        StringArrayValue = $null
        IntArrayValue    = $null
        StringValue      = $null
        IntValue         = $null
        BoolValue        = $null
    }

    # Handle different types of values
    if ($Value -is [string])
    {
        $attributeValue.StringValue = $Value
    }
    elseif ($Value -is [System.Int32] -or $Value -is [System.Int64])
    {
        $attributeValue.IntValue = $Value
    }
    elseif ($Value -is [bool])
    {
        $attributeValue.BoolValue = $Value
    }
    elseif ($Value -is [array])
    {
        if ($Value[0] -is [string])
        {
            $attributeValue.StringArrayValue = $Value
        }
        elseif ($Value[0] -is [System.Int32] -or $Value[0] -is [System.Int64])
        {
            $attributeValue.IntArrayValue = $Value
        }
    }

    return $attributeValue
}


function Get-CustomSecurityAttributes
{
    [OutputType([System.Array])]
    param (
        [String]$ServicePrincipalId
    )

    $customSecurityAttributes = Invoke-MgGraphRequest -Uri ((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/servicePrincipals/$($ServicePrincipalId)`?`$select=customSecurityAttributes") -Method Get
    $customSecurityAttributes = $customSecurityAttributes.customSecurityAttributes
    $newCustomSecurityAttributes = @()

    foreach ($key in $customSecurityAttributes.Keys)
    {
        $attributeSet = @{
            AttributeSetName = $key
            AttributeValues  = @()
        }

        foreach ($attribute in $customSecurityAttributes[$key].Keys)
        {
            # Skip properties that end with '@odata.type'
            if ($attribute -like '*@odata.type')
            {
                continue
            }

            $value = $customSecurityAttributes[$key][$attribute]
            $attributeName = $attribute # Keep the attribute name as it is

            # Create the attribute value and add it to the set
            $attributeSet.AttributeValues += Create-AttributeValue -AttributeName $attributeName -Value $value
        }

        #Add the attribute set to the final structure
        $newCustomSecurityAttributes += $attributeSet
    }

    # Display the new structure
    return [Array]$newCustomSecurityAttributes
}

Export-ModuleMember -Function *-TargetResource
