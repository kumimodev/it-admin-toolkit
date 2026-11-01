#Requires -Version 5.1
<#
.SYNOPSIS
  Lists Cyber Protect agents for a tenant using a bearer token from Get-AcronisApiToken.ps1.

.DESCRIPTION
  Uses ACRONIS_DATA_CENTER and an access token. Replace the tenant id placeholder with your lab tenant.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AccessToken,

    [Parameter(Mandatory = $true)]
    [string]$TenantId
)

$ErrorActionPreference = 'Stop'
$dc = $env:ACRONIS_DATA_CENTER
if (-not $dc) { throw 'Set ACRONIS_DATA_CENTER first.' }
$dc = $dc.TrimEnd('/')

$headers = @{
    Authorization = "Bearer $AccessToken"
    Accept        = 'application/json'
}

# Agents endpoint shape can vary by platform version. Adjust the path for your API docs.
$uri = "$dc/api/agent_manager/v2/agents?tenant_id=$TenantId"
$result = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
$result | ConvertTo-Json -Depth 6
