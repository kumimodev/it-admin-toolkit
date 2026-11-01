#Requires -Version 5.1
<#
.SYNOPSIS
  Reads Microsoft 365 Apps Click to Run configuration from the local machine.

.DESCRIPTION
  Returns channel, build and product release ids when Click to Run is installed.
  Exit code 0 when the configuration key exists. Exit code 1 when it does not.

.EXAMPLE
  .\Get-OfficeClickToRunInfo.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$cfg = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'

if (-not (Test-Path -LiteralPath $cfg)) {
    Write-Output 'Click to Run configuration key not found. Is Microsoft 365 Apps installed?'
    exit 1
}

Get-ItemProperty -LiteralPath $cfg |
    Select-Object VersionToReport, ProductReleaseIds, UpdateChannel, SharedComputerLicensing, ClientFolder

exit 0
