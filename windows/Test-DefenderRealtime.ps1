#Requires -Version 5.1
<#
.SYNOPSIS
  Reports Microsoft Defender real time protection and signature freshness.

.DESCRIPTION
  Returns a status object. Exit code 0 when real time protection is on.
  Exit code 1 when real time protection is off or Defender status cannot be read.
  Use -UpdateSignatures to refresh signatures before the check.

.PARAMETER UpdateSignatures
  Calls Update-MpSignature before reading status.

.EXAMPLE
  .\Test-DefenderRealtime.ps1

.EXAMPLE
  .\Test-DefenderRealtime.ps1 -UpdateSignatures
#>
[CmdletBinding()]
param(
    [switch]$UpdateSignatures
)

$ErrorActionPreference = 'Stop'

if ($UpdateSignatures) {
    Write-Verbose 'Updating Defender signatures...'
    Update-MpSignature -ErrorAction Stop
}

try {
    $status = Get-MpComputerStatus
}
catch {
    Write-Error "Could not read Defender status: $($_.Exception.Message)"
    exit 1
}

$result = [pscustomobject]@{
    RealTimeProtectionEnabled     = [bool]$status.RealTimeProtectionEnabled
    AntivirusEnabled              = [bool]$status.AntivirusEnabled
    AntispywareEnabled            = [bool]$status.AntispywareEnabled
    AntivirusSignatureLastUpdated = $status.AntivirusSignatureLastUpdated
    QuickScanAgeHours             = $status.QuickScanAge
    FullScanAgeHours              = $status.FullScanAge
}

$result

if (-not $result.RealTimeProtectionEnabled) {
    exit 1
}
exit 0
