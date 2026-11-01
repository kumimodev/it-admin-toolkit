#Requires -Version 5.1
<#
.SYNOPSIS
  Requests an Acronis Cyber Protect Cloud API bearer token using API client credentials.

.DESCRIPTION
  Reads ACRONIS_DATA_CENTER, ACRONIS_CLIENT_ID and ACRONIS_CLIENT_SECRET from the environment.
  Never hard code a client secret or a live tenant URL in a script you publish.
  Returns the access token string. Does not write the token to disk.

.EXAMPLE
  $env:ACRONIS_DATA_CENTER = 'https://YOUR-DATACENTER.acronis.com'
  $env:ACRONIS_CLIENT_ID = '<YourApiClientId>'
  $env:ACRONIS_CLIENT_SECRET = [Environment]::GetEnvironmentVariable('ACRONIS_CLIENT_SECRET')
  $token = .\Get-AcronisApiToken.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$dc = $env:ACRONIS_DATA_CENTER
$clientId = $env:ACRONIS_CLIENT_ID
$clientSecret = $env:ACRONIS_CLIENT_SECRET

if (-not $dc -or -not $clientId -or -not $clientSecret) {
    throw 'Set ACRONIS_DATA_CENTER, ACRONIS_CLIENT_ID and ACRONIS_CLIENT_SECRET before running this script.'
}

$dc = $dc.TrimEnd('/')
$tokenUri = "$dc/api/2/idp/token"

$body = @{
    grant_type    = 'client_credentials'
    client_id     = $clientId
    client_secret = $clientSecret
}

try {
    $response = Invoke-RestMethod -Method Post -Uri $tokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
}
catch {
    throw "Token request failed: $($_.Exception.Message)"
}

if (-not $response.access_token) {
    throw 'Token response did not include access_token.'
}

Write-Verbose ("Token acquired. Expires in {0} seconds." -f $response.expires_in)
return $response.access_token
