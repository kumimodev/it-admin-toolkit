<#
.SYNOPSIS
  Create a standard local lab user without storing a password in the script.

.NOTES
  Prefer Windows LAPS for any privileged local admin in Entra joined labs.
  This sample creates a standard user only. Change $UserName before you run it.
#>

[CmdletBinding()]
Param(
    [string]$UserName = 'LabLocalUser'
)

if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    try {
        & "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH -UserName $UserName
    }
    catch {
        throw "Failed to start $PSCOMMANDPATH"
    }
    exit
}

$existing = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "User $UserName already exists. Nothing to do."
    exit 0
}

$securePassword = Read-Host -Prompt "Enter password for local user $UserName" -AsSecureString
if (-not $securePassword -or $securePassword.Length -eq 0) {
    Write-Error 'A password is required. Prefer Windows LAPS for admin accounts instead of a long lived shared password.'
    exit 1
}

try {
    New-LocalUser -Name $UserName -Description 'Standard local lab user' -Password $securePassword -ErrorAction Stop | Out-Null
    Set-LocalUser -Name $UserName -PasswordNeverExpires $false -UserMayChangePassword $true -ErrorAction Stop
    Write-Host "Created standard local user $UserName."
    Write-Host 'For local admins on Entra joined devices, configure Windows LAPS in Intune instead of baking in a password.'
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
