function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $AppId,

        [Parameter()]
        [System.Boolean]
        $AvailableToOtherTenants,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $GroupMembershipClaims,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String[]]
        $IdentifierUris,

        [Parameter()]
        [System.Boolean]
        $IsFallbackPublicClient,

        [Parameter()]
        [System.String]
        $LogoutURL,

        [Parameter()]
        [System.String[]]
        $KnownClientApplications,

        [Parameter()]
        [System.Boolean]
        $PublicClient = $false,

        [Parameter()]
        [System.String[]]
        $ReplyURLs,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OptionalClaims,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Api,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AuthenticationBehaviors,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoles,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Permissions,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OnPremisesPublishing,

        [Parameter()]
        [System.String]
        $ApplicationTemplateId,

        [Parameter()]
        [System.String[]]
        $PublicClientRedirectUris,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Spa,

        [Parameter()]
        [ValidateSet("AzureADandPersonalMicrosoftAccount", "AzureADMultipleOrgs", "AzureADMyOrg", "PersonalMicrosoftAccount")]
        [System.String]
        $SignInAudience,

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
        if (-not $Script:exportedInstance -or $Script:exportedInstance.DisplayName -ne $DisplayName)
        {
            $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
                -InboundParameters $PSBoundParameters

            Write-Verbose -Message "Getting configuration of Azure AD Application '$DisplayName'"

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
            $AADApp = $null

            try
            {
                if (-not [System.String]::IsNullOrEmpty($AppId))
                {
                    $AADApp = Get-MgBetaApplication -Filter "AppId eq '$AppId'"
                }
            }
            catch
            {
                Write-Verbose -Message "Could not retrieve AzureAD Application by Application ID {$AppId}"
            }

            if ($null -eq $AADApp)
            {
                Write-Verbose -Message "Attempting to retrieve Azure AD Application by DisplayName {$DisplayName}"
                $AADApp = [Array](Get-MgBetaApplication -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'")
            }
            if ($null -ne $AADApp -and $AADApp.Count -gt 1)
            {
                Throw "Multiple AAD Apps with the Displayname $($DisplayName) exist in the tenant."
            }
            elseif ($null -eq $AADApp)
            {
                Write-Verbose -Message 'Could not retrieve and instance of the Azure AD App in the Get-TargetResource function.'
                return $nullReturn
            }
        }
        else
        {
            $AADApp = $Script:exportedInstance
        }
        Write-Verbose -Message 'An instance of Azure AD App was retrieved.'

        $AADBetaApp = Get-MgBetaApplication -Property 'id,displayName,appId,authenticationBehaviors,additionalProperties' -ApplicationId $AADApp.Id -ErrorAction SilentlyContinue
        $AADAppKeyCredentials = Get-MgBetaApplication -Property 'keyCredentials' -ApplicationId $AADApp.Id -ErrorAction SilentlyContinue

        $complexAuthenticationBehaviors = @{
            BlockAzureADGraphAccess    = 'Null'
            RemoveUnverifiedEmailClaim = 'Null'
            #RequireClientServicePrincipal = 'Null' #DEPRECATED
        }
        if ($null -ne $AADBetaApp.authenticationBehaviors.blockAzureADGraphAccess)
        {
            $complexAuthenticationBehaviors.BlockAzureADGraphAccess = $AADBetaApp.authenticationBehaviors.blockAzureADGraphAccess.ToString()
        }
        if ($null -ne $AADBetaApp.authenticationBehaviors.removeUnverifiedEmailClaim)
        {
            $complexAuthenticationBehaviors.RemoveUnverifiedEmailClaim = $AADBetaApp.authenticationBehaviors.removeUnverifiedEmailClaim.ToString()
        }

        $complexOptionalClaims = @{}
        $complexAccessToken = @()
        foreach ($currentAccessToken in $AADApp.optionalClaims.accessToken)
        {
            $myAccessToken = @{}
            $myAccessToken.Add('Essential', $currentAccessToken.essential)
            $myAccessToken.Add('Name', $currentAccessToken.name)
            $myAccessToken.Add('Source', $currentAccessToken.source)
            if ($myAccessToken.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexAccessToken += $myAccessToken
            }
        }
        $complexOptionalClaims.Add('AccessToken', $complexAccessToken)
        $complexIdToken = @()
        foreach ($currentIdToken in $AADApp.optionalClaims.idToken)
        {
            $myIdToken = @{}
            $myIdToken.Add('Essential', $currentIdToken.essential)
            $myIdToken.Add('Name', $currentIdToken.name)
            $myIdToken.Add('Source', $currentIdToken.source)
            if ($myIdToken.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexIdToken += $myIdToken
            }
        }
        $complexOptionalClaims.Add('IdToken', $complexIdToken)
        $complexSaml2Token = @()
        foreach ($currentSaml2Token in $AADApp.optionalClaims.saml2Token)
        {
            $mySaml2Token = @{}
            $mySaml2Token.Add('Essential', $currentSaml2Token.essential)
            $mySaml2Token.Add('Name', $currentSaml2Token.name)
            $mySaml2Token.Add('Source', $currentSaml2Token.source)
            if ($mySaml2Token.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexSaml2Token += $mySaml2Token
            }
        }
        $complexOptionalClaims.Add('Saml2Token', $complexSaml2Token)
        if ($complexOptionalClaims.values.Where({ $null -ne $_ }).Count -eq 0)
        {
            $complexOptionalClaims = $null
        }

        $complexApi = @{}
        $complexPreAuthorizedApplications = @()
        foreach ($currentPreAuthorizedApplications in $AADApp.api.preAuthorizedApplications)
        {
            $myPreAuthorizedApplications = @{}
            $myPreAuthorizedApplications.Add('AppId', $currentPreAuthorizedApplications.appId)
            $myPreAuthorizedApplications.Add('PermissionIds', $currentPreAuthorizedApplications.permissionIds)
            if ($myPreAuthorizedApplications.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexPreAuthorizedApplications += $myPreAuthorizedApplications
            }
        }

        $complexOAuth2Scopes = @()
        foreach ($currentOAuth2Scope in $AADApp.api.Oauth2PermissionScopes)
        {
            $complexOAuth2Scopes += @{
                adminConsentDescription = $currentOAuth2Scope.adminConsentDescription
                adminConsentDisplayName = $currentOAuth2Scope.adminConsentDisplayName
                id                      = $currentOAuth2Scope.id
                isEnabled               = $currentOAuth2Scope.isEnabled
                type                    = $currentOAuth2Scope.type
                userConsentDescription  = $currentOAuth2Scope.userConsentDescription
                userConsentDisplayName  = $currentOAuth2Scope.userConsentDisplayName
                value                   = $currentOAuth2Scope.value
            }
        }

        $complexApi.Add('PreAuthorizedApplications', $complexPreAuthorizedApplications)
        $complexApi.Add('Oauth2PermissionScopes', $complexOAuth2Scopes)
        if ($complexApi.values.Where({ $null -ne $_ }).Count -eq 0)
        {
            $complexApi = $null
        }

        $complexKeyCredentials = @()
        foreach ($currentkeyCredentials in $AADAppKeyCredentials.keyCredentials)
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
        foreach ($currentpasswordCredentials in $AADApp.passwordCredentials)
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

        $complexAppRoles = @()
        foreach ($currentappRoles in $AADApp.appRoles)
        {
            $myappRoles = @{}
            $myappRoles.Add('AllowedMemberTypes', $currentappRoles.allowedMemberTypes)
            $myappRoles.Add('Description', $currentappRoles.description)
            $myappRoles.Add('DisplayName', $currentappRoles.displayName)
            $myappRoles.Add('Id', $currentappRoles.id)
            $myappRoles.Add('IsEnabled', $currentappRoles.isEnabled)
            $myappRoles.Add('Origin', $currentappRoles.origin)
            $myappRoles.Add('Value', $currentappRoles.value)
            if ($myappRoles.values.Where({ $null -ne $_ }).Count -gt 0)
            {
                $complexAppRoles += $myappRoles
            }
        }

        #YK: Added Array typecasting
        [Array]$permissionsObj = Get-M365DSCAzureADAppPermissions -App $AADApp
        $isPublicClient = $false
        if (-not [System.String]::IsNullOrEmpty($AADApp.PublicClient) -and $AADApp.PublicClient -eq $true)
        {
            $isPublicClient = $true
        }

        $PublicClientRedirectUrisValue = $null
        if ($null -ne $AADApp.PublicClient -and $AADApp.PublicClient.RedirectUris.Length -gt 0)
        {
            $PublicClientRedirectUrisValue = $AADApp.PublicClient.RedirectUris
        }

        # DEPRECATED
        $AvailableToOtherTenantsValue = $false
        if ($AADApp.SignInAudience -ne 'AzureADMyOrg')
        {
            $AvailableToOtherTenantsValue = $true
        }

        [Array]$Owners = Get-MgApplicationOwner -ApplicationId $AADApp.Id -All:$true | `
                Where-Object { !$_.DeletedDateTime }
        $OwnersValues = @()
        foreach ($Owner in $Owners)
        {
            if ($Owner.AdditionalProperties.userPrincipalName)
            {
                $OwnersValues += $Owner.AdditionalProperties.userPrincipalName
            }
            else
            {
                $OwnersValues += $Owner.Id
            }
        }

        $IsFallbackPublicClientValue = $false
        if ($AADApp.IsFallbackPublicClient)
        {
            $IsFallbackPublicClientValue = $AADApp.IsFallbackPublicClient
        }

        #region OnPremisesPublishing
        $onPremisesPublishingValue = @{}
        $oppInfo = $null

        try
        {
            $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/applications/$($AADBetaApp.Id)/onPremisesPublishing"
            $oppInfo = Invoke-MgGraphRequest -Method GET `
                -Uri $Uri `
                -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Verbose -Message "On-premises publishing is not enabled for App {$($AADBetaApp.DisplayName)}"
        }

        if ($null -ne $oppInfo)
        {
            $onPremisesPublishingValue = @{
                alternateUrl                          = $oppInfo.alternateUrl
                applicationServerTimeout              = $oppInfo.applicationServerTimeout
                externalAuthenticationType            = $oppInfo.externalAuthenticationType
                externalUrl                           = $oppInfo.externalUrl
                internalUrl                           = $oppInfo.internalUrl
                isBackendCertificateValidationEnabled = $oppInfo.isBackendCertificateValidationEnabled
                isHttpOnlyCookieEnabled               = $oppInfo.isHttpOnlyCookieEnabled
                isPersistentCookieEnabled             = $oppInfo.isPersistentCookieEnabled
                isSecureCookieEnabled                 = $oppInfo.isSecureCookieEnabled
                isStateSessionEnabled                 = $oppInfo.isStateSessionEnabled
                isTranslateHostHeaderEnabled          = $oppInfo.isTranslateHostHeaderEnabled
                isTranslateLinksInBodyEnabled         = $oppInfo.isTranslateLinksInBodyEnabled
            }

            # onPremisesApplicationSegments
            $segmentValues = @()
            foreach ($segment in $oppInfo.onPremisesApplicationSegments)
            {
                $entry = @{
                    alternateUrl = $segment.AlternateUrl
                    externalUrl  = $segment.externalUrl
                    internalUrl  = $segment.internalUrl
                }

                $corsConfigurationValues = @()
                foreach ($cors in $segment.corsConfigurations)
                {
                    $corsEntry = @{
                        allowedHeaders  = [Array]($cors.allowedHeaders)
                        allowedMethods  = [Array]($cors.allowedMethods)
                        allowedOrigins  = [Array]($cors.allowedOrigins)
                        maxAgeInSeconds = $cors.maxAgeInSeconds
                        resource        = $cors.resource
                    }
                    $corsConfigurationValues += $corsEntry
                }
                $entry.Add('corsConfigurations', $corsConfigurationValues)
                $segmentValues += $entry
            }
            $onPremisesPublishingValue.Add('onPremisesApplicationSegments', $segmentValues)

            # singleSignOnSettings
            $singleSignOnValues = @{
                singleSignOnMode       = $oppInfo.singleSignOnSettings.singleSignOnMode
            }
            if ($oppInfo.singleSignOnMode.kerberosSignOnSettings)
            {
                $kerberosSignOnSettings = @{
                    kerberosServicePrincipalName       = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosServicePrincipalName
                    kerberosSignOnMappingAttributeType = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosSignOnMappingAttributeType
                }
                $singleSignOnValues.Add('kerberosSignOnSettings', $kerberosSignOnSettings)
            }
            $onPremisesPublishingValue.Add('singleSignOnSettings', $singleSignOnValues)
        }
        #endregion

        $IdentifierUrisValue = @()
        if ($null -ne $AADApp.IdentifierUris)
        {
            $IdentifierUrisValue = $AADApp.IdentifierUris
        }

        $spaValue = $null
        if ($null -ne $AADApp.Spa -and $AADApp.Spa.RedirectUris.Length -gt 0)
        {
            $spaValue = @{
                RedirectUris = $AADApp.Spa.RedirectUris
            }
        }

        $result = @{
            DisplayName              = $AADApp.DisplayName
            AvailableToOtherTenants  = $AvailableToOtherTenantsValue
            AuthenticationBehaviors  = $complexAuthenticationBehaviors
            Description              = $AADApp.Description
            GroupMembershipClaims    = $AADApp.GroupMembershipClaims
            Homepage                 = $AADApp.web.HomepageUrl
            IdentifierUris           = $IdentifierUrisValue
            IsFallbackPublicClient   = $IsFallbackPublicClientValue
            KnownClientApplications  = $AADApp.Api.KnownClientApplications
            LogoutURL                = $AADApp.web.LogoutURL
            PublicClient             = $isPublicClient
            ReplyURLs                = $AADApp.web.RedirectUris
            Owners                   = $OwnersValues
            ObjectId                 = $AADApp.Id
            AppId                    = $AADApp.AppId
            OptionalClaims           = $complexOptionalClaims
            Api                      = $complexApi
            KeyCredentials           = $complexKeyCredentials
            PasswordCredentials      = $complexPasswordCredentials
            AppRoles                 = $complexAppRoles
            Permissions              = $permissionsObj
            OnPremisesPublishing     = $onPremisesPublishingValue
            ApplicationTemplateId    = $AADApp.AdditionalProperties.applicationTemplateId
            Spa                      = $SpaValue
            PublicClientRedirectUris = $PublicClientRedirectUrisValue
            SignInAudience           = $AADApp.SignInAudience
            Ensure                   = 'Present'
            Credential               = $Credential
            ApplicationId            = $ApplicationId
            TenantId                 = $TenantId
            ApplicationSecret        = $ApplicationSecret
            CertificateThumbprint    = $CertificateThumbprint
            ManagedIdentity          = $ManagedIdentity.IsPresent
            AccessTokens             = $AccessTokens
        }

        Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
        return $result
    }
    catch
    {
        if ($Script:ExportMode)
        {
            throw $_
        }
        else
        {
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential

            throw $_
        }
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $AppId,

        [Parameter()]
        [System.Boolean]
        $AvailableToOtherTenants,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $GroupMembershipClaims,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String[]]
        $IdentifierUris,

        [Parameter()]
        [System.String[]]
        $KnownClientApplications,

        [Parameter()]
        [System.Boolean]
        $IsFallbackPublicClient,

        [Parameter()]
        [System.String]
        $LogoutURL,

        [Parameter()]
        [System.Boolean]
        $PublicClient = $false,

        [Parameter()]
        [System.String[]]
        $ReplyURLs,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OptionalClaims,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Api,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AuthenticationBehaviors,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoles,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Permissions,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OnPremisesPublishing,

        [Parameter()]
        [System.String]
        $ApplicationTemplateId,

        [Parameter()]
        [System.String[]]
        $PublicClientRedirectUris,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Spa,

        [Parameter()]
        [ValidateSet("AzureADandPersonalMicrosoftAccount", "AzureADMultipleOrgs", "AzureADMyOrg", "PersonalMicrosoftAccount")]
        [System.String]
        $SignInAudience,

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

    Write-Verbose -Message "Setting configuration of Azure AD Application '$DisplayName'"

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

    # Ensure we throw an error if PublicClient is set to $true and we're trying to also configure either Permissions
    # or IdentifierUris
    if ($PublicClient -and ($Permissions.Length -gt 0 -or $IdentifierUris.Length -gt 0))
    {
        $ErrorMessage = 'It is not possible set Permissions or IdentifierUris when the PublicClient property is ' + `
            "set to `$true. Application will not be created. To fix this, modify the configuration to set the " + `
            "PublicClient property to `$false, or remove the Permissions and IdentifierUris properties from your configuration."
        Add-M365DSCEvent -Message $ErrorMessage -EntryType 'Error' `
            -EventID 1 -Source $($MyInvocation.MyCommand.Source)
        throw $ErrorMessage
    }

    $currentAADApp = Get-TargetResource @PSBoundParameters
    $currentParameters = ([Hashtable]$PSBoundParameters).Clone()
    $currentParameters.Remove('ApplicationId') | Out-Null
    $currentParameters.Remove('TenantId') | Out-Null
    $currentParameters.Remove('CertificateThumbprint') | Out-Null
    $currentParameters.Remove('ApplicationSecret') | Out-Null
    $currentParameters.Remove('Ensure') | Out-Null
    $currentParameters.Remove('Credential') | Out-Null
    $currentParameters.Remove('ManagedIdentity') | Out-Null
    $currentParameters.Remove('AccessTokens') | Out-Null
    $backCurrentOwners = $currentAADApp.Owners
    $currentParameters.Remove('Owners') | Out-Null

    if ($KnownClientApplications)
    {
        Write-Verbose -Message 'Checking if the known client applications already exist.'
        $testedKnownClientApplications = New-Object System.Collections.Generic.List[string]
        foreach ($KnownClientApplication in $KnownClientApplications)
        {
            $knownAADApp = $null
            $knownAADApp = Get-MgApplication -Filter "AppID eq '$($KnownClientApplication)'"
            if ($null -ne $knownAADApp)
            {
                $testedKnownClientApplications.Add($knownAADApp.AppId)
            }
            else
            {
                Write-Verbose -Message "Could not find an existing app with the app ID $($KnownClientApplication)"
            }
        }
        $currentParameters.Remove('KnownClientApplications') | Out-Null
        $currentParameters.Add('KnownClientApplications', $testedKnownClientApplications)
    }

    # App should exist but it doesn't
    $needToUpdatePermissions = $false
    $needToUpdateAuthenticationBehaviors = $false
    $needToUpdateKeyCredentials = $false
    $currentParameters.Remove('AppId') | Out-Null
    $currentParameters.Remove('Permissions') | Out-Null
    $currentParameters.Remove('AuthenticationBehaviors') | Out-Null
    $currentParameters.Remove('KeyCredentials') | Out-Null
    $currentParameters.Remove('PasswordCredentials') | Out-Null
    if ($PasswordCredentials)
    {
        Write-Warning -Message 'PasswordCredentials is a readonly property and cannot be configured.'

    }

    if ($currentParameters.ContainsKey('AvailableToOtherTenants'))
    {
        Write-Verbose -Message "Property AvailableToOtherTenants is deprecated and will not have any effect. We recommend removing it from your configuration."
    }
    $currentParameters.Remove('AvailableToOtherTenants') | Out-Null
    $currentParameters.Remove('PublicClient') | Out-Null
    $currentParameters.Remove('Verbose') | Out-Null

    if ($PublicClientRedirectUris.Length -gt 0)
    {
        Write-Verbose -Message "PublicClientRedirectUris were specified"
        $PublicClientValue = @{
            RedirectUris = $PublicClientRedirectUris
        }
        $currentParameters.Add('PublicClient', $PublicClientValue)
    }
    $currentParameters.Remove('PublicClientRedirectUris') | Out-Null

    #region API
    $apiValue = @{}
    if ($currentParameters.Api.KnownClientApplications)
    {
        $apiValue.Add('KnownClientApplications', $currentParameters.Api.KnownClientApplications)
    }
    if ($currentParameters.Api.Oauth2PermissionScopes)
    {
        Write-Verbose -Message "Oauth2PermissionScopes specified and is not empty"
        $scopeValue = @()
        foreach ($scope in $currentParameters.Api.Oauth2PermissionScopes)
        {
            $scopeEntry = @{
                adminConsentDescription = $scope.adminConsentDescription
                adminConsentDisplayName = $scope.adminConsentDisplayName
                isEnabled               = $scope.isEnabled
                type                    = $scope.type
                userConsentDescription  = $scope.userConsentDescription
                userConsentDisplayName  = $scope.userConsentDisplayName
                value                   = $scope.value
            }
            if (-not [System.String]::IsNullOrEmpty($scope.id))
            {
                Write-Verbose -Message "Adding existing scope id {$($scope.id)}"
                $scopeEntry.Add('id', $scope.id)
            }
            else
            {
                Write-Verbose -Message "Generating new scope id"
                $scopeEntry.Add('id', (New-Guid).ToString())
            }

            $scopeValue += $scopeEntry
        }
        $apiValue.Add('Oauth2PermissionScopes', $scopeValue)
    }
    $currentParameters.Remove('KnownClientApplications') | Out-Null
    #endregion

    if ($currentParameters.ContainsKey('Api'))
    {
        Write-Verbose "Found existing API parameter. Updating with $(Convert-M365DscHashtableToString -Hashtable $apiValue)"
        $currentParameters.Api = $apiValue
    }
    else
    {
        Write-Verbose "Adding API parameter with $(Convert-M365DscHashtableToString -Hashtable $apiValue)"
        $currentParameters.Add('Api', $apiValue)
    }

    if ($PSBoundParameters.ContainsKey('ReplyUrls') -or `
        $PSBoundParameters.ContainsKey('LogoutURL') -or `
        $PSBoundParameters.ContainsKey('Homepage'))
    {
        $webValue = @{}

        if ($PSBoundParameters.ContainsKey('ReplyUrls'))
        {
            $webValue.Add('RedirectUris', $currentParameters.ReplyURLs)
        }
        if ($PSBoundParameters.ContainsKey('LogoutURL'))
        {
            $webValue.Add('LogoutUrl', $currentParameters.LogoutURL)
        }
        if ($PSBoundParameters.ContainsKey('Homepage'))
        {
            $webValue.Add('HomePageUrl', $currentParameters.Homepage)
        }

        $currentParameters.Add('web', $webValue)
    }
    $currentParameters.Remove('ReplyURLs') | Out-Null
    $currentParameters.Remove('LogoutURL') | Out-Null
    $currentParameters.Remove('Homepage') | Out-Null
    $currentParameters.Remove('OnPremisesPublishing') | Out-Null

    $keys = (([Hashtable]$currentParameters).clone()).Keys
    foreach ($key in $keys)
    {
        if ($null -ne $currentParameters.$key -and $currentParameters.$key.getType().Name -like '*cimInstance*')
        {
            $currentParameters.$key = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $currentParameters.$key
        }
    }

    $skipToUpdate = $false
    $AppIdValue = $null
    if ($Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent')
    {
        # Before attempting to create a new instance, let's first check to see if there is already an existing instance that is soft deleted
        if (-not [System.String]::IsNullOrEmpty($AppId))
        {
            Write-Verbose "Trying to retrieve existing deleted Applications from soft delete by Id {$AppId}."
            [Array]$deletedApp = Get-MgBetaDirectoryDeletedItemAsApplication -DirectoryObjectId $AppId -ErrorAction SilentlyContinue
        }

        if ($null -eq $deletedApp)
        {
            Write-Verbose "Trying to retrieve existing deleted Applications from soft delete by DisplayName {$DisplayName}."
            [Array]$deletedApp = Get-MgBetaDirectoryDeletedItemAsApplication -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
        }

        if ($null -ne $deletedApp -and $deletedApp.Length -eq 1)
        {
            $deletedSinceInDays = [System.DateTime]::Now.Subtract($deletedApp[0].DeletedDateTime).Days
            if ($deletedSinceInDays -le 30)
            {
                Write-Verbose -Message "Found existing deleted instance of {$DisplayName}. Restoring it instead of creating a new one. This could take a few minutes to complete."
                Restore-MgBetaDirectoryDeletedItem -DirectoryObjectId $deletedApp.Id
                $skipToUpdate = $true
                $AppIdValue = $deletedApp.Id
            }
            else
            {
                Write-Verbose -Message "Found existing deleted instance of {$DisplayName}. However, the deleted date was over days ago and it cannot be restored. Will recreate a new instance instead."
            }
        }
        elseif ($deletedApp.Length -gt 1)
        {
            Write-Verbose -Message "Multiple instances of a deleted application with name {$DisplayName} wehre found. Creating a new instance since we can't determine what instance to restore."
        }
    }

    # Create from Template
    $createdFromTemplate = $false
    if ($Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent' -and -not $skipToUpdate -and `
            -not [System.String]::IsNullOrEmpty($ApplicationTemplateId) -and `
            $ApplicationTemplateId -ne '8adf8e6e-67b2-4cf2-a259-e3dc5476c621')
    {
        $skipToUpdate = $true
        Write-Verbose -Message "Creating application {$DisplayName} from Application Template {$ApplicationTemplateId}"
        $newApp = Invoke-MgBetaInstantiateApplicationTemplate -DisplayName $DisplayName `
            -ApplicationTemplateId $ApplicationTemplateId
        $currentAADApp = @{
            AppId       = $newApp.Application.AppId
            Id          = $newApp.Application.AppId
            DisplayName = $newApp.Application.DisplayName
            ObjectId    = $newApp.Application.AdditionalProperties.objectId
        }

        $createdFromTemplate = $true

        do
        {
            Write-Verbose -Message 'Waiting for 10 seconds'
            Start-Sleep -Seconds 10
            $appEntity = Get-MgApplication -ApplicationId $currentAADApp.AppId -ErrorAction SilentlyContinue
            $tries++
        } until ($null -eq $appEntity -or $tries -le 12)
    }

    if ($Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Absent' -and -not $skipToUpdate)
    {
        $currentParameters.Remove('ObjectId') | Out-Null
        $currentParameters.Remove('ApplicationTemplateId') | Out-Null
        Write-Verbose -Message "Creating New AzureAD Application {$DisplayName} with values:`r`n$($currentParameters | Out-String)"

        Write-Verbose -Message "Parameters with API: $(ConvertTo-Json $currentParameters -Depth 10)"
        $currentAADApp = New-MgApplication @currentParameters
        Write-Verbose -Message "Azure AD Application {$DisplayName} was successfully created"
        $needToUpdatePermissions = $true
        $needToUpdateAuthenticationBehaviors = $true
        $needToUpdateKeyCredentials = $true

        $tries = 1
        $appEntity = $null
        do
        {
            Write-Verbose -Message 'Waiting for 10 seconds'
            Start-Sleep -Seconds 10
            $appEntity = Get-MgApplication -ApplicationId $currentAADApp.AppId -ErrorAction SilentlyContinue
            $tries++
        } until ($null -eq $appEntity -or $tries -le 12)

    }
    # App should exist and will be configured to desired state
    elseif (($Ensure -eq 'Present' -and $currentAADApp.Ensure -eq 'Present') -or $skipToUpdate)
    {
        $currentParameters.Remove('ObjectId') | Out-Null
        $currentParameters.Remove('ApplicationTemplateId') | Out-Null

        if (-not $skipToUpdate -or $createdFromTemplate)
        {
            $AppIdValue = $currentAADApp.ObjectId
        }

        $currentParameters.Add('ApplicationId', $AppIdValue)
        $currentParameters.Remove('AppRoles') | Out-Null

        Write-Verbose -Message "Updating existing AzureAD Application {$DisplayName} with values:`r`n$($currentParameters | Out-String)"
        Update-MgApplication @currentParameters

        if (-not $currentAADApp.ContainsKey('ID'))
        {
            $currentAADApp.Add('ID', $AppIdValue)
        }
        $needToUpdatePermissions = $true
        $needToUpdateAuthenticationBehaviors = $true
        $needToUpdateKeyCredentials = $true

        # Update AppRoles
        if ($null -ne $AppRoles)
        {
            Write-Verbose -Message "AppRoles were specified."

            # Find roles to Remove
            $fixedRoles = @()
            $rolesToRemove = @()
            foreach ($currentRole in $currentAADApp.AppRoles)
            {
                $associatedDesiredRoleEntry = $AppRoles | Where-Object -FilterScript {$_.DisplayName -eq $currentRole.DisplayName}
                if ($null -eq $associatedDesiredRoleEntry)
                {
                    Write-Verbose -Message "Could not find matching AppRole entry in Desired values for {$($currentRole.DisplayName)}. Will remove role."
                    $fixedRole = $currentRole
                    $fixedRole.IsEnabled = $false
                    $fixedRoles += $fixedRole
                    $rolesToRemove += $currentRole.DisplayName
                }
                else
                {
                    Write-Verbose -Message "Found matching AppRole entry in Desired values for {$($currentRole.DisplayName)}. Keeping same value as current, but setting to disable."
                    $entry = @{
                        AllowedMemberTypes = $currentRole.AllowedMemberTypes
                        Id                 = $currentRole.Id
                        IsEnabled          = $false
                        Origin             = $currentRole.Origin
                        Value              = $currentRole.Value
                        DisplayName        = $currentRole.DisplayName
                        Description        = $currentRole.Description
                    }
                    $fixedRoles += $entry
                }
            }

            Write-Verbose -Message "Updating AppRoles with the disabled roles to remove: {$($rolesToRemove -join ',')}"
            Update-MgApplication -ApplicationId $currentAADApp.ObjectId -AppRoles $fixedRoles

            Write-Verbose -Message "Updating the app a second time, this time removing the app roles {$($rolesToRemove -join ',')} and updating the others."
            $resultingAppRoles = @()
            foreach ($currentAppRole in $AppRoles)
            {
                $entry = @{
                    AllowedMemberTypes = $currentAppRole.AllowedMemberTypes
                    Id                 = $currentAppRole.Id
                    IsEnabled          = $currentAppRole.IsEnabled
                    Origin             = $currentAppRole.Origin
                    Value              = $currentAppRole.Value
                    DisplayName        = $currentAppRole.DisplayName
                    Description        = $currentAppRole.Description
                }
                $resultingAppRoles += $entry
            }
            Update-MgApplication -ApplicationId $currentAADApp.ObjectId -AppRoles $resultingAppRoles
        }
    }
    # App exists but should not
    elseif ($Ensure -eq 'Absent' -and $currentAADApp.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing AzureAD Application {$DisplayName} by ObjectID {$($currentAADApp.ObjectID)}"
        Remove-MgApplication -ApplicationId $currentAADApp.ObjectID
    }

    if ($Ensure -ne 'Absent')
    {
        $desiredOwnersValue = @()
        if ($Owners.Length -gt 0)
        {
            $desiredOwnersValue = $Owners
        }
        if (!$backCurrentOwners)
        {
            $backCurrentOwners = @()
        }
        $ownersDiff = Compare-Object -ReferenceObject $backCurrentOwners -DifferenceObject $desiredOwnersValue
        foreach ($diff in $ownersDiff)
        {
            if ($diff.SideIndicator -eq '=>')
            {
                Write-Verbose -Message "Adding new owner {$($diff.InputObject)} to AAD Application {$DisplayName}"
                if ($diff.InputObject.Contains('@'))
                {
                    $Type = 'users'
                }
                else
                {
                    $Type = 'directoryObjects'
                }
                $ObjectUri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'v1.0/{0}/{1}' -f $Type, $diff.InputObject
                $ownerObject = @{
                    '@odata.id' = $ObjectUri
                }
                try
                {
                    New-MgApplicationOwnerByRef -ApplicationId $currentAADApp.ObjectId -BodyParameter $ownerObject | Out-Null
                }
                catch
                {
                    New-M365DSCLogEntry -Message 'Error updating data:' `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                }
            }
            elseif ($diff.SideIndicator -eq '<=')
            {
                Write-Verbose -Message "Removing new owner {$($diff.InputObject)} from AAD Application {$DisplayName}"
                try
                {
                    if ($diff.InputObject.Contains('@'))
                    {
                        $ObjectId = $(Get-MgUser -UserId $diff.InputObject -ErrorAction Stop).Id
                    }
                    else
                    {
                        $ObjectId = $diff.InputObject
                    }
                    Remove-MgApplicationOwnerDirectoryObjectByRef -ApplicationId $currentAADApp.ObjectId -DirectoryObjectId $ObjectId -ErrorAction Stop
                }
                catch
                {
                    New-M365DSCLogEntry -Message 'Error updating data:' `
                        -Exception $_ `
                        -Source $($MyInvocation.MyCommand.Source) `
                        -TenantId $TenantId `
                        -Credential $Credential
                }
            }
        }
    }

    if ($needToUpdatePermissions -and $null -ne $Permissions)
    {
        Write-Verbose -Message "Will update permissions for Azure AD Application {$($currentAADApp.DisplayName)}"

        if ($Permissions.Length -eq 0)
        {
            Write-Verbose -Message "Desired set of permissions is empty, removing all permissions on the app."
            $allRequiredAccess = @()
        }
        else
        {
            $allSourceAPIs = $Permissions.SourceAPI | Select-Object -Unique
            $allRequiredAccess = @()

            foreach ($sourceAPI in $allSourceAPIs)
            {
                Write-Verbose -Message "Adding permissions for API {$($sourceAPI)}"
                $permissionsForcurrentAPI = $Permissions | Where-Object -FilterScript { $_.SourceAPI -eq $sourceAPI }
                $apiPrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$($sourceAPI -replace "'", "''")'"
                $currentAPIAccess = @{
                    ResourceAppId  = $apiPrincipal.AppId
                    ResourceAccess = @()
                }
                foreach ($permission in $permissionsForcurrentAPI)
                {
                    if ($permission.Type -eq 'Delegated')
                    {
                        $scope = $apiPrincipal.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Value -eq $permission.Name }
                        $scopeId = $null
                        if ($null -eq $scope)
                        {
                            $ObjectGuid = [System.Guid]::empty
                            if ([System.Guid]::TryParse($permission.Name, [System.Management.Automation.PSReference]$ObjectGuid))
                            {
                                $scopeId = $permission.Name
                            }
                        }
                        else
                        {
                            $scopeId = $scope.Id
                        }
                        Write-Verbose -Message "Adding Delegated Permission {$($scopeId)}"
                        $delPermission = @{
                            Id   = $scopeId
                            Type = 'Scope'
                        }
                        $currentAPIAccess.ResourceAccess += $delPermission
                    }
                    elseif ($permission.Type -eq 'AppOnly')
                    {
                        $role = $apiPrincipal.AppRoles | Where-Object -FilterScript { $_.Value -eq $permission.Name }
                        $roleId = $null
                        if ($null -eq $role)
                        {
                            $ObjectGuid = [System.Guid]::empty
                            if ([System.Guid]::TryParse($permission.Name, [System.Management.Automation.PSReference]$ObjectGuid))
                            {
                                $roleId = $permission.Name
                            }
                        }
                        else
                        {
                            $roleId = $role.Id
                        }
                        if ([System.String]::IsNullOrEmpty($roleId))
                        {
                            throw "Could not find associated role {$($permission.Name)} for API {$($sourceAPI)}"
                        }
                        $appPermission = @{
                            Id   = $roleId
                            Type = 'Role'
                        }
                        $currentAPIAccess.ResourceAccess += $appPermission
                    }
                }
                if ($null -ne $currentAPIAccess)
                {
                    $allRequiredAccess += $currentAPIAccess
                }
            }
        }

        Write-Verbose -Message "Updating permissions for Azure AD Application {$($currentAADApp.DisplayName)} with RequiredResourceAccess:`r`n$($allRequiredAccess | Out-String)"
        Write-Verbose -Message "ResourceAccess:`r`n$($allRequiredAccess.ResourceAccess | Out-String)"
        Write-Verbose -Message "Current App Id: $($currentAADApp.AppId)"

        # Even if the property is named ApplicationId, we need to pass in the ObjectId
        Update-MgApplication -ApplicationId ($currentAADApp.Id) `
            -RequiredResourceAccess $allRequiredAccess | Out-Null
    }

    if ($needToUpdateAuthenticationBehaviors -and $AuthenticationBehaviors)
    {
        Write-Verbose -Message "Updating for Azure AD Application {$($currentAADApp.DisplayName)} with AuthenticationBehaviors:`r`n$($AuthenticationBehaviors| Out-String)"
        Write-Verbose -Message "Current App Id: $($currentAADApp.AppId)"

        $IAuthenticationBehaviors = @{
            blockAzureADGraphAccess       = $AuthenticationBehaviors.blockAzureADGraphAccess
            removeUnverifiedEmailClaim    = $AuthenticationBehaviors.removeUnverifiedEmailClaim
        }

        Update-MgBetaApplication -ApplicationId $currentAADApp.Id -BodyParameter @{
            authenticationBehaviors = $IAuthenticationBehaviors
        }
    }

    if ($needToUpdateKeyCredentials -and $KeyCredentials)
    {
        Write-Verbose -Message "Updating for Azure AD Application {$($currentAADApp.DisplayName)} with KeyCredentials:`r`n$($KeyCredentials| Out-String)"

        if (($currentAADApp.KeyCredentials.Length -eq 0 -and $KeyCredentials.Length -eq 1) -or ($currentAADApp.KeyCredentials.Length -eq 1 -and $KeyCredentials.Length -eq 0))
        {
            Update-MgApplication -ApplicationId $currentAADApp.Id -KeyCredentials $KeyCredentials | Out-Null
        }
        else
        {
            Write-Warning -Message 'KeyCredentials cannot be updated for AAD Applications with more than one KeyCredentials due to technical limitation of Update-MgApplication Cmdlet. Learn more at: https://learn.microsoft.com/en-us/graph/api/application-addkey'
        }
    }

    #region OnPremisesPublishing
    if ($null -ne $OnPremisesPublishing)
    {
        $oppInfo = $OnPremisesPublishing
        $onPremisesPublishingValue = @{
            alternateUrl                          = $oppInfo.alternateUrl
            applicationServerTimeout              = $oppInfo.applicationServerTimeout
            externalAuthenticationType            = $oppInfo.externalAuthenticationType
            #externalUrl                           = $oppInfo.externalUrl
            internalUrl                           = $oppInfo.internalUrl
            isBackendCertificateValidationEnabled = $oppInfo.isBackendCertificateValidationEnabled
            isHttpOnlyCookieEnabled               = $oppInfo.isHttpOnlyCookieEnabled
            isPersistentCookieEnabled             = $oppInfo.isPersistentCookieEnabled
            isSecureCookieEnabled                 = $oppInfo.isSecureCookieEnabled
            isStateSessionEnabled                 = $oppInfo.isStateSessionEnabled
            isTranslateHostHeaderEnabled          = $oppInfo.isTranslateHostHeaderEnabled
            isTranslateLinksInBodyEnabled         = $oppInfo.isTranslateLinksInBodyEnabled
        }

        # onPremisesApplicationSegments
        $segmentValues = @()
        foreach ($segment in $oppInfo.onPremisesApplicationSegments)
        {
            $entry = @{
                alternateUrl = $segment.AlternateUrl
                externalUrl  = $segment.externalUrl
                internalUrl  = $segment.internalUrl
            }

            $corsConfigurationValues = @()
            foreach ($cors in $segment.corsConfigurations)
            {
                $corsEntry = @{
                    allowedHeaders  = [Array]($cors.allowedHeaders)
                    allowedMethods  = [Array]($cors.allowedMethods)
                    allowedOrigins  = [Array]($cors.allowedOrigins)
                    maxAgeInSeconds = $cors.maxAgeInSeconds
                    resource        = $cors.resource
                }
                $corsConfigurationValues += $corsEntry
            }
            $entry.Add('corsConfigurations', $corsConfigurationValues)
            $segmentValues += $entry
        }
        $onPremisesPublishingValue.Add('onPremisesApplicationSegments', $segmentValues)

        # singleSignOnSettings
        $singleSignOnValues = @{
            kerberosSignOnSettings = @{
                kerberosServicePrincipalName       = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosServicePrincipalName
                kerberosSignOnMappingAttributeType = $oppInfo.singleSignOnSettings.kerberosSignOnSettings.kerberosSignOnMappingAttributeType
            }
            singleSignOnMode       = $oppInfo.singleSignOnSettings.singleSignOnMode
        }
        if ($null -eq $singleSignOnValues.kerberosSignOnSettings.kerberosServicePrincipalName)
        {
            $singleSignOnValues.Remove('kerberosSignOnSettings') | Out-Null
        }

        $onPremisesPublishingValue.Add('singleSignOnSettings', $singleSignOnValues)
        $onPremisesPayload = ConvertTo-Json $onPremisesPublishingValue -Depth 10 -Compress
        Write-Verbose -Message "Updating the OnPremisesPublishing settings for application {$($currentAADApp.DisplayName)} with payload: $onPremisesPayload"

        $Uri = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/applications/$($currentAADApp.Id)/onPremisesPublishing"
        Invoke-MgGraphRequest -Method 'PATCH' `
            -Uri $Uri `
            -Body $onPremisesPayload
    }
    #endregion
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $ObjectId,

        [Parameter()]
        [System.String]
        $AppId,

        [Parameter()]
        [System.Boolean]
        $AvailableToOtherTenants,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $GroupMembershipClaims,

        [Parameter()]
        [System.String]
        $Homepage,

        [Parameter()]
        [System.String[]]
        $IdentifierUris,

        [Parameter()]
        [System.Boolean]
        $IsFallbackPublicClient,

        [Parameter()]
        [System.String[]]
        $KnownClientApplications,

        [Parameter()]
        [System.String]
        $LogoutURL,

        [Parameter()]
        [System.Boolean]
        $PublicClient = $false,

        [Parameter()]
        [System.String[]]
        $ReplyURLs,

        [Parameter()]
        [System.String[]]
        $Owners,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OptionalClaims,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Api,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $AuthenticationBehaviors,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $KeyCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $PasswordCredentials,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppRoles,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Permissions,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $OnPremisesPublishing,

        [Parameter()]
        [System.String]
        $ApplicationTemplateId,

        [Parameter()]
        [System.String[]]
        $PublicClientRedirectUris,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Spa,

        [Parameter()]
        [ValidateSet("AzureADandPersonalMicrosoftAccount", "AzureADMultipleOrgs", "AzureADMyOrg", "PersonalMicrosoftAccount")]
        [System.String]
        $SignInAudience,

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

    Write-Verbose -Message "Testing configuration of AzureAD Application '$DisplayName'"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()
    $testTargetResource = $true

    if ($CurrentValues.Ensure -eq 'Absent' -and $Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Both the desired and current value for Ensure are set to Absent. Therefore ignoring the drift assessment."
        return $true
    }

    #Compare Cim instances
    foreach ($key in $PSBoundParameters.Keys)
    {
        $source = $PSBoundParameters.$key
        $target = $CurrentValues.$key
        if ($null -ne $source -and $source.GetType().Name -like '*CimInstance*')
        {
            if (-not ($source.GetType().Name -eq 'CimInstance[]' -and $source.Count -eq 0))
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
            else
            {
                $ValuesToCheck.Remove($key) | Out-Null
            }
        }
    }

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck.Remove('ObjectId') | Out-Null
    $ValuesToCheck.Remove('AppId') | Out-Null
    $ValuesToCheck.Remove('AvailableToOtherTenants') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    $dscContent = [System.Text.StringBuilder]::new()
    $i = 1
    Write-M365DSCHost -Message "`r`n" -DeferWrite
    try
    {
        $Script:ExportMode = $true
        [array] $Script:exportedInstances = Get-MgBetaApplication -Filter $Filter -All -ErrorAction Stop
        foreach ($AADApp in $Script:exportedInstances)
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-M365DSCHost -Message "    |---[$i/$($Script:exportedInstances.Count)] $($AADApp.DisplayName)" -DeferWrite
            $Params = @{
                ApplicationId         = $ApplicationId
                AppId                 = $AADApp.AppId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                ApplicationSecret     = $ApplicationSecret
                Description           = $AADApp.Description
                DisplayName           = $AADApp.DisplayName
                ObjectID              = $AADApp.Id
                Credential            = $Credential
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }
            try
            {
                $Script:exportedInstance = $AADApp
                $Results = Get-TargetResource @Params
                if ($Results.Ensure -eq 'Present')
                {

                    if ($Results.Permissions.Count -gt 0)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'Permissions'
                                CimInstanceName = 'MSFT_AADApplicationPermission'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.Permissions `
                            -CIMInstanceName 'MSFT_AADApplicationPermission' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.Permissions = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Permissions') | Out-Null
                        }
                    }

                    if ($null -ne $Results.Api)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'Api'
                                CimInstanceName = 'MicrosoftGraphApiApplication'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'PreAuthorizedApplications'
                                CimInstanceName = 'MicrosoftGraphPreAuthorizedApplication'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'Oauth2PermissionScopes'
                                CimInstanceName = 'MSFT_MicrosoftGraphApiOauth2PermissionScopes'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.Api `
                            -CIMInstanceName 'MicrosoftGraphapiApplication' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.Api = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Api') | Out-Null
                        }
                    }

                    if ($null -ne $Results.AuthenticationBehaviors -and $Results.AuthenticationBehaviors.Length -gt 0)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.AuthenticationBehaviors `
                            -CIMInstanceName 'MicrosoftGraphauthenticationBehaviors'
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.AuthenticationBehaviors = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('AuthenticationBehaviors') | Out-Null
                        }
                    }

                    if ($null -ne $Results.Spa -and $Results.Spa.Length -gt 0)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.Spa `
                            -CIMInstanceName 'AADApplicationSpa'
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.Spa = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Spa') | Out-Null
                        }
                    }

                    if ($null -ne $Results.OnPremisesPublishing.singleSignOnSettings)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'singleSignOnSettings'
                                CimInstanceName = 'AADApplicationOnPremisesPublishingSingleSignOnSetting'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'onPremisesApplicationSegments'
                                CimInstanceName = 'AADApplicationOnPremisesPublishingSegment'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'kerberosSignOnSettings'
                                CimInstanceName = 'AADApplicationOnPremisesPublishingSingleSignOnSettingKerberos'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'corsConfigurations'
                                CimInstanceName = 'AADApplicationOnPremisesPublishingSegmentCORS'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.OnPremisesPublishing `
                            -CIMInstanceName 'AADApplicationOnPremisesPublishing' `
                            -ComplexTypeMapping $complexMapping
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.OnPremisesPublishing = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('OnPremisesPublishing') | Out-Null
                        }
                    }
                    else
                    {
                        $Results.Remove('OnPremisesPublishing') | Out-Null
                    }

                    if ($null -ne $Results.OptionalClaims)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'OptionalClaims'
                                CimInstanceName = 'MicrosoftGraphOptionalClaims'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'AccessToken'
                                CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'IdToken'
                                CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'Saml2Token'
                                CimInstanceName = 'MicrosoftGraphOptionalClaim'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.OptionalClaims `
                            -CIMInstanceName 'MicrosoftGraphoptionalClaims' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.OptionalClaims = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('OptionalClaims') | Out-Null
                        }
                    }

                    if ($null -ne $Results.KeyCredentials)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.KeyCredentials `
                            -CIMInstanceName 'MicrosoftGraphkeyCredential'
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
                            -CIMInstanceName 'MicrosoftGraphpasswordCredential'
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.PasswordCredentials = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('PasswordCredentials') | Out-Null
                        }
                    }

                    if ($null -ne $Results.AppRoles)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.AppRoles `
                            -CIMInstanceName 'MicrosoftGraphappRole'
                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.AppRoles = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('AppRoles') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $PSScriptRoot `
                        -Results $Results `
                        -Credential $Credential `
                        -NoEscape @('Api', 'Permissions', 'OptionalClaims', 'OnPremisesPublishing', 'AuthenticationBehaviors', 'KeyCredentials', 'PasswordCredentials', 'AppRoles', 'Spa')

                    $dscContent.Append($currentDSCBlock) | Out-Null
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
            }
            catch
            {
                if ($_.Exception.Message -like '*Multiple AAD Apps with the Displayname*')
                {
                    Write-M365DSCHost -Message "`r`n        $($Global:M365DSCEmojiYellowCircle)" -DeferWrite
                    Write-M365DSCHost -Message " Multiple app instances wth name {$($AADApp.DisplayName)} were found. We will skip exporting these instances." -CommitWrite
                }
                New-M365DSCLogEntry -Message 'Error during Export:' `
                    -Exception $_ `
                    -Source $($MyInvocation.MyCommand.Source) `
                    -TenantId $TenantId `
                    -Credential $Credential
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
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

function Get-M365DSCAzureADAppPermissions
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        $App
    )
    Write-Verbose -Message "Retrieving permissions for Azure AD Application {$($App.DisplayName)}"
    [array]$requiredAccesses = $App.RequiredResourceAccess

    $permissions = @()
    $i = 1
    foreach ($requiredAccess in $requiredAccesses)
    {
        Write-Verbose -Message "[$i/$($requiredAccesses.Length)]Obtaining information for App's Permission for {$($requiredAccess.ResourceAppId)}"
        $SourceAPI = Get-MgServicePrincipal -Filter "AppId eq '$($requiredAccess.ResourceAppId)'"
        $appServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'" -All:$true
        if ($null -ne $appServicePrincipal)
        {
            $oAuth2grant = Get-MgBetaOauth2PermissionGrant -Filter "ClientId eq '$($appServicePrincipal.Id)'"
            $roleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $appServicePrincipal.Id
        }

        foreach ($resourceAccess in $requiredAccess.ResourceAccess)
        {
            $currentPermission = @{}
            $currentPermission.Add('SourceAPI', $SourceAPI.DisplayName)
            if ($resourceAccess.Type -eq 'Scope')
            {
                $scopeInfo = $SourceAPI.Oauth2PermissionScopes | Where-Object -FilterScript { $_.Id -eq $resourceAccess.Id }
                $scopeInfoValue = $null
                if ($null -eq $scopeInfo)
                {
                    $ObjectGuid = [System.Guid]::empty
                    if ([System.Guid]::TryParse($resourceAccess.Id, [System.Management.Automation.PSReference]$ObjectGuid))
                    {
                        $scopeInfoValue = $resourceAccess.Id
                    }
                }
                else
                {
                    $scopeInfoValue = $scopeInfo.Value
                }
                $currentPermission.Add('Type', 'Delegated')
                $currentPermission.Add('Name', $scopeInfoValue)
                $currentPermission.Add('AdminConsentGranted', $false)

                if ($null -ne $appServicePrincipal)
                {
                    if ($null -ne $oAuth2grant)
                    {
                        $scopes = $oAuth2grant.Scope.Split(' ')
                        if ($scopes.Contains($scopeInfoValue))
                        {
                            $currentPermission.AdminConsentGranted = $true
                        }
                    }
                }
            }
            elseif ($resourceAccess.Type -eq 'Role' -or $resourceAccess.Type -eq 'Role,Scope')
            {
                $currentPermission.Add('Type', 'AppOnly')
                $role = $SourceAPI.AppRoles | Where-Object -FilterScript { $_.Id -eq $resourceAccess.Id }
                $roleValue = $null
                if ($null -eq $role)
                {
                    $ObjectGuid = [System.Guid]::empty
                    if ([System.Guid]::TryParse($resourceAccess.Id, [System.Management.Automation.PSReference]$ObjectGuid))
                    {
                        $roleValue = $resourceAccess.Id
                    }
                }
                else
                {
                    $roleValue = $role.Value
                }
                $currentPermission.Add('Name', $roleValue)
                $currentPermission.Add('AdminConsentGranted', $false)

                if ($null -ne $appServicePrincipal)
                {
                    $foundPermission = $roleAssignments | Where-Object -FilterScript { $_.AppRoleId -eq $resourceAccess.Id }
                    if ($foundPermission)
                    {
                        $currentPermission.AdminConsentGranted = $true
                    }
                }
            }
            $permissions += $currentPermission
        }
        $i++
    }

    return $permissions
}

Export-ModuleMember -Function *-TargetResource
