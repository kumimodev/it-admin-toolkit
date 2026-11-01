#Requires -Version 5.1
<#
.SYNOPSIS
  Reads Microsoft 365 Apps Click to Run configuration from the local machine.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$cfg = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
if (-not (Test-Path $cfg)) {
    Write-Host 'Click to Run configuration key not found. Is Microsoft 365 Apps installed?'
    return
}

Get-ItemProperty $cfg |
    Select-Object VersionToReport, ProductReleaseIds, UpdateChannel, SharedComputerLicensing, ClientFolder |
    Format-List
