﻿# EXOSharedMailbox

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **DisplayName** | Key | String | The display name of the Shared Mailbox | |
| **Identity** | Write | String | The unique identifier of the Shared Mailbox | |
| **PrimarySMTPAddress** | Write | String | The primary email address of the Shared Mailbox | |
| **Alias** | Write | String | The alias of the Shared Mailbox | |
| **EmailAddresses** | Write | StringArray[] | The EmailAddresses parameter specifies all the email addresses (proxy addresses) for the Shared Mailbox | |
| **AuditEnabled** | Write | Boolean | The AuditEnabled parameter specifies whether to enable or disable mailbox audit logging for the mailbox. If auditing is enabled, actions specified in the AuditAdmin, AuditDelegate, and AuditOwner parameters are logged | |
| **Ensure** | Write | String | Present ensures the group exists, absent ensures it is removed | `Present`, `Absent` |
| **Credential** | Write | PSCredential | Credentials of the Exchange Global Admin | |
| **ApplicationId** | Write | String | Id of the Azure Active Directory application to authenticate with. | |
| **TenantId** | Write | String | Id of the Azure Active Directory tenant used for authentication. | |
| **CertificateThumbprint** | Write | String | Thumbprint of the Azure Active Directory application's authentication certificate to use for authentication. | |
| **CertificatePassword** | Write | PSCredential | Username can be made up to anything but password will be used for CertificatePassword | |
| **CertificatePath** | Write | String | Path to certificate used in service principal usually a PFX file. | |
| **ManagedIdentity** | Write | Boolean | Managed ID being used for authentication. | |
| **AccessTokens** | Write | StringArray[] | Access token used for authentication. | |

## Description

This resource allows users to create Office 365 Shared Mailboxes.

## Permissions

### Exchange

To authenticate with Microsoft Exchange, this resource required the following permissions:

#### Roles

- Mail Enabled Public Folders, MyName, Public Folders, Compliance Admin, User Options, Message Tracking, View-Only Recipients, Role Management, Legal Hold, Audit Logs, Retention Management, Distribution Groups, Move Mailboxes, Information Rights Management, Mail Recipient Creation, Reset Password, View-Only Audit Logs, Mail Recipients, Mailbox Search, UM Mailboxes, Security Group Creation and Membership, Mailbox Import Export, MyMailboxDelegation, MyDisplayName

#### Role Groups

- Organization Management

## Examples

### Example 1

This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.

```powershell
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
        EXOSharedMailbox 'SharedMailbox'
        {
            DisplayName        = "Integration"
            PrimarySMTPAddress = "Integration@$TenantId"
            EmailAddresses     = @("IntegrationSM@$TenantId")
            Alias              = "IntegrationSM"
            Ensure             = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
```

### Example 2

This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.

```powershell
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
        EXOSharedMailbox 'SharedMailbox'
        {
            DisplayName        = "Integration"
            PrimarySMTPAddress = "Integration@$TenantId"
            EmailAddresses     = @("IntegrationSM@$TenantId", "IntegrationSM2@$TenantId")
            Alias              = "IntegrationSM"
            Ensure             = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
```

### Example 3

This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.

```powershell
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
        EXOSharedMailbox 'SharedMailbox'
        {
            DisplayName        = "Integration"
            PrimarySMTPAddress = "Integration@$TenantId"
            EmailAddresses     = @("IntegrationSM@$TenantId", "IntegrationSM2@$TenantId")
            Alias              = "IntegrationSM"
            Ensure             = "Absent"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
```

