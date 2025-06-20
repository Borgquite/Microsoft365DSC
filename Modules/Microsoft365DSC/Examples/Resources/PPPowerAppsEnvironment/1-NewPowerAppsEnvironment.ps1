<#
This example creates a new PowerApps environment in production.
#>

Configuration Example
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credscredential
    )
    Import-DscResource -ModuleName Microsoft365DSC

    node localhost
    {
        PPPowerAppsEnvironment 'PowerAppsDemoEnvironment'
        {
            DisplayName        = "My Demo Environment"
            EnvironmentSKU     = "Production"
            Location           = "canada"
            ProvisionDatabase  = $true
            LanguageName       = 1033;
            CurrencyName	   = "CAD";
            Ensure             = "Present"
            Credential         = $Credscredential
        }
    }
}
