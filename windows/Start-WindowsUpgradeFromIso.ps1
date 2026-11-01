#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Mounts a Windows setup ISO and starts setup.exe for an in place upgrade.

.DESCRIPTION
  Pass a lab ISO path and a log folder. The ISO is dismounted in a finally block.
  Do not hard code a production media share.

.PARAMETER IsoPath
  Full path to the Windows ISO.

.PARAMETER LogDirectory
  Folder for setup copy logs.

.EXAMPLE
  .\Start-WindowsUpgradeFromIso.ps1 -IsoPath 'D:\LabMedia\Win11.iso' -LogDirectory 'C:\LabLogs\WinUpgrade'
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
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

$mounted = $false
try {
    $mount = Mount-DiskImage -ImagePath $IsoPath -PassThru | Get-Volume
    $mounted = $true
    $drive = "$($mount.DriveLetter):"
    $setup = Join-Path $drive 'setup.exe'
    if (-not (Test-Path -LiteralPath $setup)) {
        throw "setup.exe missing on $drive"
    }

    Write-Verbose "Launching setup from $setup"
    $setupArgs = @(
        '/auto', 'upgrade',
        '/eula', 'accept',
        '/dynamicupdate', 'disable',
        '/telemetry', 'disable',
        '/copylogs', $LogDirectory
    )
    $p = Start-Process -FilePath $setup -ArgumentList $setupArgs -Wait -PassThru
    Write-Output "setup.exe exited with code $($p.ExitCode)"
    exit $p.ExitCode
}
finally {
    if ($mounted) {
        Dismount-DiskImage -ImagePath $IsoPath | Out-Null
        Write-Verbose 'ISO dismounted.'
    }
}
