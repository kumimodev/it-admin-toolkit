#Requires -Version 5.1
<#
.SYNOPSIS
  Exports installed Win32 and AppX package names to a CSV for lab inventory.
#>
[CmdletBinding()]
param(
    [string]$OutputPath = '.\installed-apps.csv'
)

$ErrorActionPreference = 'Stop'
$rows = @()

$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
foreach ($path in $uninstallRoots) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        ForEach-Object {
            $rows += [pscustomobject]@{
                Name        = $_.DisplayName
                Version     = $_.DisplayVersion
                Publisher   = $_.Publisher
                Source      = 'Win32'
            }
        }
}

Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
    ForEach-Object {
        $rows += [pscustomobject]@{
            Name      = $_.Name
            Version   = $_.Version.ToString()
            Publisher = $_.Publisher
            Source    = 'AppX'
        }
    }

$rows | Sort-Object Name | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
Write-Host "Wrote $($rows.Count) rows to $OutputPath"
