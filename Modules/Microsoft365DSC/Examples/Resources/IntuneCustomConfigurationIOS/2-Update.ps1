<#
This example updates a new Intune Custom Configuration Policy for iOs devices
#>

Configuration Example
{
    param(
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )
    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        IntuneCustomConfigurationIOS "ConfigureIntuneCustomConfigurationIOS"
        {
            Description            = "IntuneCustomConfigurationIOS Description - NEW VALUE";
            DisplayName            = "IntuneCustomConfigurationIOS DisplayName";
            Ensure                 = "Present";
            Payload                = "PHJvb3Q+PC9yb290Pg==";
            PayloadFileName        = "simple.xml";
            PayloadName            = "IntuneCustomConfigurationIOS DisplayName";
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
