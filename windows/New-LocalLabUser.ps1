#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Creates a standard local lab user without storing a password in the script.

.DESCRIPTION
  Prompts for a SecureString password. Prefer Windows LAPS for privileged local admins.
  Idempotent when the user already exists.

.PARAMETER UserName
  Local account name. Default is LabLocalUser.

.EXAMPLE
  .\New-LocalLabUser.ps1

.EXAMPLE
  .\New-LocalLabUser.ps1 -UserName 'LabUser01'
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateNotNullOrEmpty()]
    [string]$UserName = 'LabLocalUser'
)

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess($UserName, 'Create local lab user')) {
    return
}


if ($env:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    $sysNative = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\PowerShell.exe'
    & $sysNative -ExecutionPolicy Bypass -NoProfile -File $PSCommandPath -UserName $UserName
    exit $LASTEXITCODE
}

$existing = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Output "User $UserName already exists. Nothing to do."
    exit 0
}

$securePassword = Read-Host -Prompt "Enter password for local user $UserName" -AsSecureString
if (-not $securePassword -or $securePassword.Length -eq 0) {
    Write-Error 'A password is required. Prefer Windows LAPS for admin accounts.'
    exit 1
}

try {
    New-LocalUser -Name $UserName -Description 'Standard local lab user' -Password $securePassword -ErrorAction Stop | Out-Null
    Set-LocalUser -Name $UserName -PasswordNeverExpires $false -UserMayChangePassword $true -ErrorAction Stop
    Write-Output "Created standard local user $UserName."
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
