#Requires -Version 5.1
<#
.SYNOPSIS
  Exports installed Win32 and AppX package names to a CSV for lab inventory.

.PARAMETER OutputPath
  Destination CSV path. Default is .\installed-apps.csv

.EXAMPLE
  .\Export-InstalledApps.ps1

.EXAMPLE
  .\Export-InstalledApps.ps1 -OutputPath "$env:USERPROFILE\Desktop\apps.csv"
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$OutputPath = '.\installed-apps.csv'
)

$ErrorActionPreference = 'Stop'

if (-not $PSCmdlet.ShouldProcess($OutputPath, 'Export installed apps CSV')) {
    return
}

try {

$rows = New-Object System.Collections.Generic.List[object]

$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

foreach ($path in $uninstallRoots) {
    Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        ForEach-Object {
            $rows.Add([pscustomobject]@{
                Name      = $_.DisplayName
                Version   = $_.DisplayVersion
                Publisher = $_.Publisher
                Source    = 'Win32'
            })
        }
}

Get-AppxPackage -ErrorAction SilentlyContinue |
    ForEach-Object {
        $rows.Add([pscustomobject]@{
            Name      = $_.Name
            Version   = $_.Version.ToString()
            Publisher = $_.Publisher
            Source    = 'AppX'
        })
    }

$dir = Split-Path -Parent $OutputPath
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$rows | Sort-Object Name | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
Write-Output "Wrote $($rows.Count) rows to $OutputPath"
exit 0
}
catch {
    Write-Error "Export failed: $($_.Exception.Message)"
    exit 1
}
