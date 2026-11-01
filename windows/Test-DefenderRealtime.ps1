#Requires -Version 5.1
<#
.SYNOPSIS
  Checks Microsoft Defender real time protection and signature age.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$status = Get-MpComputerStatus
[pscustomobject]@{
    RealTimeProtectionEnabled     = $status.RealTimeProtectionEnabled
    AntivirusEnabled              = $status.AntivirusEnabled
    AntispywareEnabled            = $status.AntispywareEnabled
    AntivirusSignatureLastUpdated = $status.AntivirusSignatureLastUpdated
    QuickScanAgeHours             = $status.QuickScanAge
    FullScanAgeHours              = $status.FullScanAge
} | Format-List
