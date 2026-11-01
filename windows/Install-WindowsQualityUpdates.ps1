#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Installs available Windows quality updates in a lab script or Win32 context.

.DESCRIPTION
  Uses the PSWindowsUpdate module from the PowerShell Gallery.
  Exit codes follow common Intune Win32 reboot conventions:
  0 = success, no reboot required
  3010 = soft reboot suggested
  1641 = hard reboot requested with -HardReboot

.PARAMETER HardReboot
  Return 1641 instead of 3010 when a reboot is required.

.EXAMPLE
  .\Install-WindowsQualityUpdates.ps1

.EXAMPLE
  .\Install-WindowsQualityUpdates.ps1 -HardReboot
#>
[CmdletBinding()]
param(
    [switch]$HardReboot
)

$ErrorActionPreference = 'Stop'

if ("$env:PROCESSOR_ARCHITEW6432" -ne 'ARM64') {
    $sysNative = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path -LiteralPath $sysNative) {
        & $sysNative -ExecutionPolicy Bypass -NoProfile -File $PSCommandPath @PSBoundParameters
        exit $LASTEXITCODE
    }
}

$tagDir = Join-Path $env:ProgramData 'ITAdminToolkit\UpdateOS'
if (-not (Test-Path -LiteralPath $tagDir)) {
    New-Item -ItemType Directory -Path $tagDir -Force | Out-Null
}
Set-Content -Path (Join-Path $tagDir 'Install-WindowsQualityUpdates.tag') -Value (Get-Date -Format 'o')
$logPath = Join-Path $tagDir 'Install-WindowsQualityUpdates.log'
Start-Transcript -Path $logPath | Out-Null

try {
    Write-Verbose "Installing updates. HardReboot=$HardReboot"

    $null = Install-PackageProvider -Name NuGet -Force
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
    }
    Import-Module PSWindowsUpdate -Force

    Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -WindowsUpdate -IgnoreReboot |
        Select-Object Title, KB, Result |
        Format-Table | Out-String | Write-Verbose

    $needReboot = $false
    try {
        $needReboot = [bool](Get-WURebootStatus -Silent).RebootRequired
    }
    catch {
        Write-Warning "Could not read reboot status: $($_.Exception.Message)"
    }

    if (-not $needReboot) {
        Write-Output 'Updates finished. No reboot required.'
        exit 0
    }

    if ($HardReboot) {
        Write-Output 'Updates finished. Hard reboot requested (1641).'
        exit 1641
    }

    Write-Output 'Updates finished. Soft reboot suggested (3010).'
    exit 3010
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    Stop-Transcript | Out-Null
}
