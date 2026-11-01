#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Mounts a Windows setup ISO and starts setup.exe for an in place upgrade.

.DESCRIPTION
  Use a lab ISO path. Logs go to a folder you choose. Do not hard code a production media share.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IsoPath,

    [Parameter(Mandatory = $true)]
    [string]$LogDirectory
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $IsoPath)) {
    throw "ISO not found: $IsoPath"
}
if (-not (Test-Path -LiteralPath $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory | Out-Null
}

$mount = Mount-DiskImage -ImagePath $IsoPath -PassThru | Get-Volume
$drive = "$($mount.DriveLetter):"
$setup = Join-Path $drive 'setup.exe'
if (-not (Test-Path -LiteralPath $setup)) {
    Dismount-DiskImage -ImagePath $IsoPath | Out-Null
    throw "setup.exe missing on $drive"
}

Write-Host "Launching setup from $setup"
$args = @(
    '/auto', 'upgrade',
    '/eula', 'accept',
    '/dynamicupdate', 'disable',
    '/telemetry', 'disable',
    '/copylogs', $LogDirectory
)
try {
    $p = Start-Process -FilePath $setup -ArgumentList $args -Wait -PassThru
    Write-Host "setup.exe exited with code $($p.ExitCode)"
}
finally {
    Dismount-DiskImage -ImagePath $IsoPath | Out-Null
    Write-Host 'ISO dismounted.'
}
