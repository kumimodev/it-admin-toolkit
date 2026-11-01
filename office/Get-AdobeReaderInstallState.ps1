#Requires -Version 5.1
<#
.SYNOPSIS
  Reports whether Adobe Acrobat Reader appears installed and which DisplayVersion is registered.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$hits = foreach ($p in $paths) {
    Get-ItemProperty $p -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match 'Adobe (Acrobat )?Reader' }
}
if (-not $hits) {
    Write-Host 'No Adobe Reader uninstall entry found.'
    return
}
$hits | Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation | Format-List
