#Requires -Version 5.1
<#
.SYNOPSIS
  Requests an Acronis Cyber Protect Cloud API bearer token using API client credentials.

.DESCRIPTION
  Reads ACRONIS_DATA_CENTER, ACRONIS_CLIENT_ID and ACRONIS_CLIENT_SECRET from the environment.
  Never hard code a client secret or a live tenant URL in a script you publish.
  Example data centre host placeholder: https://eu2-cloud.acronis.com

.NOTES
  Create an API client in the Acronis management console under Settings > API clients.
  Scope the client to the least privilege your automation needs.
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

$response = Invoke-RestMethod -Method Post -Uri $tokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
if (-not $response.access_token) {
    throw 'Token response did not include access_token.'
}

Write-Host 'Token acquired. Expires in seconds:' $response.expires_in
# Return for piping into other helpers. Do not write the token to disk.
return $response.access_token
