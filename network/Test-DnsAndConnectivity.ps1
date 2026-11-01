#Requires -Version 5.1
<#
.SYNOPSIS
  Runs DNS and HTTPS checks against well known public endpoints.

.DESCRIPTION
  Useful for quick lab troubleshooting. Returns one object per name.
  Exit code 0 when every name resolves. Exit code 1 when any DNS lookup fails.

.PARAMETER Names
  Hostnames to test. Defaults cover public DNS and Microsoft sign in.

.PARAMETER FlushDns
  Flushes the local DNS client cache before testing.

.EXAMPLE
  .\Test-DnsAndConnectivity.ps1

.EXAMPLE
  .\Test-DnsAndConnectivity.ps1 -FlushDns -Names 'dns.google','login.microsoftonline.com'
#>
[CmdletBinding()]
param(
    [string[]]$Names = @('dns.google', 'one.one.one.one', 'login.microsoftonline.com'),
    [switch]$FlushDns
)

$ErrorActionPreference = 'Continue'

if ($FlushDns) {
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Verbose 'DNS client cache flushed.'
}

$failed = 0
foreach ($name in $Names) {
    $dns = Resolve-DnsName -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    $okHttp = $false
    try {
        $null = Invoke-WebRequest -Uri "https://$name" -UseBasicParsing -TimeoutSec 8 -MaximumRedirection 0 -ErrorAction Stop
        $okHttp = $true
    }
    catch {
        if ($_.Exception.Response) {
            $okHttp = $true
        }
    }

    $dnsOk = [bool]$dns
    if (-not $dnsOk) { $failed++ }

    [pscustomobject]@{
        Name             = $name
        DnsOk            = $dnsOk
        ResolvedAddress  = if ($dns.IPAddress) { $dns.IPAddress } elseif ($dns.NameHost) { $dns.NameHost } else { $null }
        HttpsReachable   = $okHttp
    }
}

if ($failed -gt 0) {
    exit 1
}
exit 0
