# Install the latest winget msixbundle from the microsoft/winget-cli GitHub release.

$ProgressPreference = 'SilentlyContinue'
$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
$bundleUri = $release.assets.browser_download_url | Where-Object { $_.EndsWith('.msixbundle') } | Select-Object -First 1
$bundleName = Split-Path -Path $bundleUri -Leaf

Write-Host "Downloading $bundleName"
Invoke-WebRequest -Uri $bundleUri -OutFile $bundleName
Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx'

Add-AppxPackage -Path 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
Add-AppxPackage -Path $bundleName
Write-Host 'winget install finished'
