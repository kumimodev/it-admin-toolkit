#Requires -Version 5.1
<#
.SYNOPSIS
  Collects username, hostname and BIOS serial for lab enrolment notes.

.DESCRIPTION
  Writes a small text file under the current user Downloads folder by default.
  Prefer this over legacy WMIC based batch helpers.

.PARAMETER OutputDirectory
  Folder for the report. Default is Downloads\LabEnrolmentNotes.

.EXAMPLE
  .\Get-LabDeviceInfo.ps1
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $env:USERPROFILE 'Downloads\LabEnrolmentNotes')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$who = whoami
$hostName = $env:COMPUTERNAME
$outFile = Join-Path $OutputDirectory ("DeviceInfo_{0}.txt" -f $env:USERNAME)

@(
    'Domain\Username'
    $who
    '-----'
    'Hostname'
    $hostName
    '-----'
    'BIOS SerialNumber'
    $serial
) | Set-Content -Path $outFile -Encoding UTF8

Write-Output "Wrote $outFile"
[pscustomobject]@{
    UserName     = $who
    Hostname     = $hostName
    SerialNumber = $serial
    ReportPath   = $outFile
}
exit 0
