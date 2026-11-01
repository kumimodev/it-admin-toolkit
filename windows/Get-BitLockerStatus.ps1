#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Summarises BitLocker volume protection state for the local machine.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Get-BitLockerVolume | Select-Object MountPoint, VolumeType, VolumeStatus, ProtectionStatus, EncryptionPercentage, KeyProtector |
    Format-Table -AutoSize
