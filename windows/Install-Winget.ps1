#Requires -Version 5.1
<#
.SYNOPSIS
  Installs the latest winget msixbundle from the microsoft/winget-cli GitHub release.

.DESCRIPTION
  Downloads the Desktop VCLibs dependency and the latest winget msixbundle into a temp folder,
  then registers both with Add-AppxPackage. Idempotent when winget is already on PATH.

.EXAMPLE
  .\Install-Winget.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = 'Stop'
if (-not $PSCmdlet.ShouldProcess('winget', 'Install winget from GitHub release')) {
    return
}

$ProgressPreference = 'SilentlyContinue'

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Output "winget already available: $((winget --version) 2>$null)"
    exit 0
}

$work = Join-Path $env:TEMP ("winget-install-" + [guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Path $work -Force | Out-Null

try {
    Write-Verbose 'Resolving latest winget release...'
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
    $bundleUri = $release.assets |
        Where-Object { $_.name -like '*.msixbundle' } |
        Select-Object -ExpandProperty browser_download_url -First 1
    if (-not $bundleUri) {
        throw 'Could not find an msixbundle asset on the latest winget release.'
    }

    $bundlePath = Join-Path $work (Split-Path -Path $bundleUri -Leaf)
    $vclibsPath = Join-Path $work 'Microsoft.VCLibs.x64.14.00.Desktop.appx'

    Write-Verbose "Downloading $bundleUri"
    Invoke-WebRequest -Uri $bundleUri -OutFile $bundlePath
    Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vclibsPath

    Add-AppxPackage -Path $vclibsPath -ErrorAction Stop
    Add-AppxPackage -Path $bundlePath -ErrorAction Stop

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Packages registered but winget is not on PATH yet. Open a new shell and retry.'
    }
    Write-Output "winget installed: $(winget --version)"
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
