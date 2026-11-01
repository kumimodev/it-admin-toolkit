<#
.SYNOPSIS
  Install available Windows quality updates in a lab Win32 or script context.
#>

[CmdletBinding()]
Param(
    [switch]$HardReboot
)

if ("$env:PROCESSOR_ARCHITEW6432" -ne 'ARM64') {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -NoProfile -File $PSCommandPath @PSBoundParameters
        exit $LASTEXITCODE
    }
}

$tagDir = "$($env:ProgramData)\IntuneHomeLab\UpdateOS"
if (-not (Test-Path $tagDir)) {
    New-Item -ItemType Directory -Path $tagDir -Force | Out-Null
}
Set-Content -Path (Join-Path $tagDir 'UpdateOS.ps1.tag') -Value 'Installed'
Start-Transcript (Join-Path $tagDir 'UpdateOS.log') | Out-Null

Write-Host "Installing updates. HardReboot = $HardReboot"

$null = Install-PackageProvider -Name NuGet -Force
$null = Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -WindowsUpdate -IgnoreReboot |
    Select-Object Title, KB, Result |
    Format-Table

$needReboot = (Get-WURebootStatus -Silent).RebootRequired
if ($needReboot) {
    Write-Host 'Windows Update indicated that a reboot is needed.'
}
else {
    Write-Host 'Windows Update indicated that no reboot is required.'
}

if ($HardReboot) {
    Write-Host 'Exiting with return code 1641 for a hard reboot.'
    Stop-Transcript | Out-Null
    exit 1641
}

Write-Host 'Exiting with return code 3010 for a soft reboot.'
Stop-Transcript | Out-Null
exit 3010
