#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Creates a local scan folder, local user and SMB share for a lab multifunction printer.

.DESCRIPTION
  Prompts for the account password. Never commit a plaintext password.
  Safe to re-run. Existing user, folder and share are left in place.

.PARAMETER AccountName
  Local account used by the scanner. Default is LabScan.

.PARAMETER FolderPath
  Folder that receives scans. Default is C:\LabScan.

.PARAMETER ShareName
  SMB share name. Default is LabScan.

.EXAMPLE
  .\New-LabScanShare.ps1

.EXAMPLE
  .\New-LabScanShare.ps1 -AccountName 'LabScan' -FolderPath 'D:\LabScan' -ShareName 'LabScan'
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateNotNullOrEmpty()]
    [string]$AccountName = 'LabScan',

    [ValidateNotNullOrEmpty()]
    [string]$FolderPath = 'C:\LabScan',

    [ValidateNotNullOrEmpty()]
    [string]$ShareName = 'LabScan'
)

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess($FolderPath, 'Create lab scan share')) {
    return
}


if ($env:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    $sysNative = Join-Path $env:WINDIR 'SysNative\WindowsPowerShell\v1.0\PowerShell.exe'
    & $sysNative -ExecutionPolicy Bypass -NoProfile -File $PSCommandPath -AccountName $AccountName -FolderPath $FolderPath -ShareName $ShareName
    exit $LASTEXITCODE
}

if (-not (Get-LocalUser -Name $AccountName -ErrorAction SilentlyContinue)) {
    $securePassword = Read-Host -Prompt "Enter password for local user $AccountName" -AsSecureString
    if (-not $securePassword -or $securePassword.Length -eq 0) {
        Write-Error 'A password is required.'
        exit 1
    }
    New-LocalUser -Name $AccountName -Password $securePassword -Description 'Lab scan share account' -ErrorAction Stop | Out-Null
    Set-LocalUser -Name $AccountName -PasswordNeverExpires $false -UserMayChangePassword $true
    Write-Output "Created local user $AccountName"
}
else {
    Write-Output "Local user $AccountName already exists"
}

if (-not (Test-Path -LiteralPath $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath -ErrorAction Stop | Out-Null
    Write-Output "Created folder $FolderPath"
}

try {
    $acl = Get-Acl -Path $FolderPath
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $AccountName,
        'FullControl',
        'ContainerInherit,ObjectInherit',
        'None',
        'Allow'
    )
    $acl.SetAccessRule($rule)
    Set-Acl -Path $FolderPath -AclObject $acl
    Write-Output "Granted NTFS rights on $FolderPath to $AccountName"
}
catch {
    Write-Warning "NTFS ACL warning: $($_.Exception.Message)"
}

if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $FolderPath -FullAccess $AccountName -Description 'Lab multifunction scanner destination' -ErrorAction Stop | Out-Null
    Write-Output "Created SMB share $ShareName"
}
else {
    Write-Output "SMB share $ShareName already exists"
}

exit 0
