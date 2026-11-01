#Requires -Version 5.1
<#
.SYNOPSIS
  Quick DNS and HTTPS checks against well known public endpoints for lab troubleshooting.
#>
[CmdletBinding()]
param(
    [string[]]$Names = @('dns.google', 'one.one.one.one', 'login.microsoftonline.com')
)

$ErrorActionPreference = 'Continue'
foreach ($name in $Names) {
    $dns = Resolve-DnsName -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    $okHttp = $false
    try {
        $null = Invoke-WebRequest -Uri "https://$name" -UseBasicParsing -TimeoutSec 8 -MaximumRedirection 0 -ErrorAction Stop
        $okHttp = $true
    } catch {
        # Many hosts refuse a bare GET. Treat TCP/TLS reachability separately if needed.
        if ($_.Exception.Response) { $okHttp = $true }
    }
    [pscustomobject]@{
        Name           = $name
        DnsOk          = [bool]$dns
        ResolvedAddress = if ($dns.IPAddress) { $dns.IPAddress } elseif ($dns.NameHost) { $dns.NameHost } else { $null }
        HttpsReachable = $okHttp
    }
}
