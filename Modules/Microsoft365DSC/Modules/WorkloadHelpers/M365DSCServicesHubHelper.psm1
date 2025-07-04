function Invoke-M365DSCServicesHubWebRequest
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter()]
        [System.String]
        $Method = 'GET',

        [Parameter()]
        [System.Collections.Hashtable]
        $Body
    )

    $headers = @{
        Authorization = (Get-MSCloudLoginConnectionProfile -Workload 'EngageHub').AccessToken
    }

    $bodyValue = $null
    if (-not [System.String]::IsNullOrEmpty($Body))
    {
        $bodyValue = ConvertTo-Json $Body -Depth 20 -Compress
    }

    try
    {
        $response = Invoke-WebRequest -Method $Method `
                                      -Uri $Uri `
                                      -Headers $headers `
                                      -Body $bodyValue `
                                      -ContentType 'application/json; charset=utf-8' `
                                      -UseBasicParsing
    }
    catch
    {
        $statusCode = $_.Exception.Response.StatusCode
        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
        $streamReader.Close()
        throw $ErrResp
    }
    $result = $null
    if ($response.Content.Length -gt 0)
    {
        $result = ConvertFrom-Json $response.Content -ErrorAction SilentlyContinue
    }
    return $result
}
