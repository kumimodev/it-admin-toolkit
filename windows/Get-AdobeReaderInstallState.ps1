#Requires -Version 5.1
<#
.SYNOPSIS
  Reports whether Adobe Acrobat Reader is registered in Uninstall keys.

.DESCRIPTION
  Searches 64 bit and 32 bit Uninstall registry trees.
  Exit code 0 when at least one matching entry is found. Exit code 1 otherwise.

.EXAMPLE
  .\Get-AdobeReaderInstallState.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$hits = foreach ($p in $paths) {
    Get-ItemProperty -Path $p -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Adobe (Acrobat )?Reader' }
}

if (-not $hits) {
    Write-Output 'No Adobe Reader uninstall entry found.'
    exit 1
}

$hits | Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation
exit 0
