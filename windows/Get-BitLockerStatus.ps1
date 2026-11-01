#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Returns BitLocker volume protection state for the local machine.

.DESCRIPTION
  Emits objects you can pipe to Format-Table or Export-Csv. Run elevated.

.EXAMPLE
  .\Get-BitLockerStatus.ps1

.EXAMPLE
  .\Get-BitLockerStatus.ps1 | Export-Csv -Path .\bitlocker.csv -NoTypeInformation
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

try {
    Get-BitLockerVolume | Select-Object @(
        'MountPoint',
        'VolumeType',
        'VolumeStatus',
        'ProtectionStatus',
        'EncryptionPercentage',
        'KeyProtector'
    )
}
catch {
    Write-Error "Could not read BitLocker status: $($_.Exception.Message)"
    exit 1
}
