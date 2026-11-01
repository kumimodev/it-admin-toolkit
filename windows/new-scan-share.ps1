<#
.SYNOPSIS
  Create a local scan folder, local user, and SMB share for a lab multifunction printer.

.NOTES
  Prompts for the password. Never commit a plaintext password.
  Replace $AccountName and $FolderPath for your lab.
#>

[CmdletBinding()]
Param(
    [string]$AccountName = 'LabScan',
    [string]$FolderPath = 'C:\LabScan',
    [string]$ShareName = 'LabScan'
)

if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    try {
        & "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH -AccountName $AccountName -FolderPath $FolderPath -ShareName $ShareName
    }
    catch {
        throw "Failed to start $PSCOMMANDPATH"
    }
    exit
}

if (-not (Get-LocalUser -Name $AccountName -ErrorAction SilentlyContinue)) {
    $securePassword = Read-Host -Prompt "Enter password for local user $AccountName" -AsSecureString
    if (-not $securePassword -or $securePassword.Length -eq 0) {
        Write-Error 'A password is required.'
        exit 1
    }
    New-LocalUser -Name $AccountName -Password $securePassword -Description 'Lab scan share account' -ErrorAction Stop | Out-Null
    Set-LocalUser -Name $AccountName -PasswordNeverExpires $false -UserMayChangePassword $true
    Write-Host "Created local user $AccountName"
}
else {
    Write-Host "Local user $AccountName already exists"
}

if (-not (Test-Path -Path $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath -ErrorAction Stop | Out-Null
    Write-Host "Created folder $FolderPath"
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
    Write-Host "Granted NTFS rights on $FolderPath to $AccountName"
}
catch {
    Write-Warning "NTFS ACL warning: $_"
}

if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $FolderPath -FullAccess $AccountName -Description 'Lab multifunction scanner destination' -ErrorAction Stop | Out-Null
    Write-Host "Created SMB share $ShareName"
}
else {
    Write-Host "SMB share $ShareName already exists"
}

exit 0
