@{
    Dependencies = @(
        @{
            ModuleName      = 'Az.Accounts'
            RequiredVersion = '3.0.2'
        },
        @{
            ModuleName      = 'Az.ResourceGraph'
            RequiredVersion = '1.0.0'
        },
        @{
            ModuleName      = 'Az.Resources'
            RequiredVersion = '7.2.0'
        },
        @{
            ModuleName      = 'Az.SecurityInsights'
            RequiredVersion = '3.1.2'
        },
        @{
            ModuleName      = 'DSCParser'
            RequiredVersion = '2.0.0.17'
        },
        @{
            ModuleName      = 'ExchangeOnlineManagement'
            RequiredVersion = '3.8.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Applications'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Applications'
            Requiredversion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Authentication'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.DeviceManagement'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Devices.CorporateManagement'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.DeviceManagement.Administration'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.DeviceManagement.Enrollment'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.NetworkAccess'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Identity.DirectoryManagement'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Identity.DirectoryManagement'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Identity.Governance'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Identity.SignIns'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Identity.SignIns'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Reports'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Search'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Teams'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.DeviceManagement.Administration'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.DirectoryObjects'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Groups'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Beta.Groups'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Planner'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Sites'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Users'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'Microsoft.Graph.Users.Actions'
            RequiredVersion = '2.28.0'
        },
        @{
            ModuleName      = 'MicrosoftTeams'
            RequiredVersion = '7.0.0'
        },
        @{
            ModuleName      = "MSCloudLoginAssistant"
            RequiredVersion = "1.1.45"
        },
        @{
            ModuleName      = 'PnP.PowerShell'
            RequiredVersion = '1.12.0'
            InstallLocation = 'WindowsPowerShell'
        },
        @{
            ModuleName      = 'PSDesiredStateConfiguration'
            RequiredVersion = '2.0.7'
            PowerShellCore  = $true
            ExplicitLoading = $true
            Prefix          = 'Pwsh'
        },
        @{
            ModuleName      = 'ReverseDSC'
            RequiredVersion = '2.0.0.28'
        }
    )
}
