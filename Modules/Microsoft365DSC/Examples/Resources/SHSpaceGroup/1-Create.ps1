<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
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
    Import-DscResource -ModuleName Microsoft365DSC
    node localhost
    {
        SHSpaceGroup "SHSpaceGroup"
        {
            ApplicationId         = $ApplicationId;
            CertificateThumbprint = $CertificateThumbprint;
            Ensure                = "Present";
            GroupName             = "TestApplications";
            Roles                 = @("TrainingPermissionRole","CustomerActivityPagePermissionRole","InviteUsersPermissionRole");
            SpaceName             = "Test Workspace";
            TenantId              = $TenantId;
        }
    }
}
