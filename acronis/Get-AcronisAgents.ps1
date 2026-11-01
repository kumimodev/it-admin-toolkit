#Requires -Version 5.1
<#
.SYNOPSIS
  Lists Cyber Protect agents for a tenant using a bearer token from Get-AcronisApiToken.ps1.

.DESCRIPTION
  Uses ACRONIS_DATA_CENTER and an access token you supply.
  Replace the tenant id with a lab value. Endpoint paths can vary by platform version.

.PARAMETER AccessToken
  Bearer token from Get-AcronisApiToken.ps1.

.PARAMETER TenantId
  Acronis tenant id (GUID).

.EXAMPLE
  $token = .\Get-AcronisApiToken.ps1
  .\Get-AcronisAgents.ps1 -AccessToken $token -TenantId '00000000-0000-0000-0000-000000000000'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-fA-F-]{36}$')]
    [string]$TenantId
)

$ErrorActionPreference = 'Stop'
$dc = $env:ACRONIS_DATA_CENTER
if (-not $dc) {
    throw 'Set ACRONIS_DATA_CENTER first.'
}
$dc = $dc.TrimEnd('/')

$headers = @{
    Authorization = "Bearer $AccessToken"
    Accept        = 'application/json'
}

$uri = "$dc/api/agent_manager/v2/agents?tenant_id=$TenantId"
try {
    $result = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
}
catch {
    throw "Agent list request failed: $($_.Exception.Message)"
}

$result
