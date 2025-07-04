function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Yes')]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $GroupLifetimeInDays,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('All', 'Selected', 'None')]
        $ManagedGroupTypes,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AlternateNotificationEmails,

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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $PSBoundParameters

    Write-Verbose -Message 'Getting configuration of AzureAD Groups Lifecycle Policy'

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

    try
    {
        $nullReturn = $PSBoundParameters
        $nullReturn.Ensure = 'Absent'

        try
        {
            $Policy = Get-MgGroupLifecyclePolicy -ErrorAction SilentlyContinue
        }
        catch
        {
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential
        }

        if ($null -eq $Policy)
        {
            return $nullReturn
        }
        else
        {
            Write-Verbose 'Found existing AzureAD Groups Lifecycle Policy'
            $result = @{
                IsSingleInstance            = 'Yes'
                GroupLifetimeInDays         = $Policy.GroupLifetimeInDays
                ManagedGroupTypes           = $Policy.ManagedGroupTypes
                AlternateNotificationEmails = $Policy.AlternateNotificationEmails.Split(';')
                Ensure                      = 'Present'
                Credential                  = $Credential
                ApplicationId               = $ApplicationId
                ApplicationSecret           = $ApplicationSecret
                TenantId                    = $TenantId
                CertificateThumbprint       = $CertificateThumbprint
                Managedidentity             = $ManagedIdentity.IsPresent
                AccessTokens                = $AccessTokens
            }

            Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
            return $result
        }
    }
    catch
    {
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
        [ValidateSet('Yes')]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $GroupLifetimeInDays,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('All', 'Selected', 'None')]
        $ManagedGroupTypes,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AlternateNotificationEmails,

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

    Write-Verbose -Message 'Setting configuration of Azure AD Groups Lifecycle Policy'

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

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $PSBoundParameters

    try
    {
        $policy = Get-MgGroupLifecyclePolicy -ErrorAction SilentlyContinue
    }
    catch
    {
        Write-Verbose -Message $_
        return
    }

    $currentPolicy = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "The Group Lifecycle Policy should exist but it doesn't. Creating it."
        $creationParams = $PSBoundParameters
        $creationParams.Remove('IsSingleInstance') | Out-Null
        $creationParams.Remove('Credential') | Out-Null
        $creationParams.Remove('ApplicationId') | Out-Null
        $creationParams.Remove('TenantId') | Out-Null
        $creationParams.Remove('CertificateThumbprint') | Out-Null
        $creationParams.Remove('ManagedIdentity') | Out-Null
        $creationParams.Remove('Ensure') | Out-Null
        $creationParams.Remove('AccessTokens') | Out-Null

        $emails = ''
        foreach ($email in $creationParams.AlternateNotificationEmails)
        {
            $emails += $email + ';'
        }
        $emails = $emails.TrimEnd(';')
        $creationParams.AlternateNotificationEmails = $emails
        New-MgGroupLifecyclePolicy @creationParams
    }
    elseif ($Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
    {
        $updateParams = $PSBoundParameters
        $updateParams.Remove('IsSingleInstance') | Out-Null
        $updateParams.Remove('Credential') | Out-Null
        $updateParams.Remove('ApplicationId') | Out-Null
        $updateParams.Remove('TenantId') | Out-Null
        $updateParams.Remove('CertificateThumbprint') | Out-Null
        $updateParams.Remove('ManagedIdentity') | Out-Null
        $updateParams.Remove('Ensure') | Out-Null
        $updateParams.Remove('AccessTokens') | Out-Null

        $emails = ''
        foreach ($email in $updateParams.AlternateNotificationEmails)
        {
            $emails += $email + ';'
        }
        $emails = $emails.TrimEnd(';')
        $updateParams.AlternateNotificationEmails = $emails
        $updateParams.Add('GroupLifecyclePolicyId', (Get-MgGroupLifecyclePolicy).Id)

        Write-Verbose -Message "The Group Lifecycle Policy exists but it's not in the Desired State. Updating it."
        Update-MgGroupLifecyclePolicy @updateParams
    }
    elseif ($Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
    {
        Write-Verbose -Message 'The Group Lifecycle Policy should NOT exist but it DOES. Removing it.'
        Remove-MgGroupLifecyclePolicy -GroupLifecyclePolicyId (Get-MgGroupLifecyclePolicy).Id
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
        [ValidateSet('Yes')]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $GroupLifetimeInDays,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('All', 'Selected', 'None')]
        $ManagedGroupTypes,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AlternateNotificationEmails,

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

    Write-Verbose -Message 'Testing configuration of AzureAD Groups Lifecycle Policy'

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
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
    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' -InboundParameters $PSBoundParameters

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

    $organization = ''
    $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
    try
    {
        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
        {
            $Global:M365DSCExportResourceInstancesCount++
        }

        if ($ConnectionMode -eq 'ServicePrincipalWithThumbprint')
        {
            $organization = Get-M365DSCTenantDomain -ApplicationId $ApplicationId `
                -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint
        }
        elseif ($ConnectionMode -eq 'ServicePrincipalWithSecret')
        {
            $organization = Get-M365DSCTenantDomain -ApplicationId $ApplicationId `
                -TenantId $TenantId -ApplicationSecret $ApplicationSecret
        }
        elseif ($ConnectionMode -eq 'ManagedIdentity')
        {
            $organization = $TenantId
        }
        else
        {
            if ($null -ne $Credential -and $Credential.UserName.Contains('@'))
            {
                $organization = $Credential.UserName.Split('@')[1]
            }
        }
        if ($organization.IndexOf('.') -gt 0)
        {
            $principal = $organization.Split('.')[0]
        }

        try
        {
            $Policy = Get-MgGroupLifecyclePolicy -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return ''
        }

        $dscContent = ''

        $Params = @{
            Credential                  = $Credential
            IsSingleInstance            = 'Yes'
            GroupLifetimeInDays         = 1
            ManagedGroupTypes           = 'All'
            AlternateNotificationEmails = 'empty@contoso.com'
            ApplicationId               = $ApplicationId
            ApplicationSecret           = $ApplicationSecret
            TenantId                    = $TenantId
            CertificateThumbprint       = $CertificateThumbprint
            Managedidentity             = $ManagedIdentity.IsPresent
            AccessTokens                = $AccessTokens
        }
        $Results = Get-TargetResource @Params
        if ($Results.Ensure -eq 'Present')
        {

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
        }

        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

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
