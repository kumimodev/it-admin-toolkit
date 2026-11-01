# Windows helpers

| Script | Purpose |
| --- | --- |
| `Get-LabDeviceInfo.ps1` | Username, hostname and BIOS serial for enrolment notes |
| `Get-BitLockerStatus.ps1` | BitLocker volume protection summary |
| `Test-DefenderRealtime.ps1` | Defender real time status, optional signature update |
| `Get-OfficeClickToRunInfo.ps1` | Microsoft 365 Apps Click to Run channel and build |
| `Get-AdobeReaderInstallState.ps1` | Adobe Reader uninstall registry check |
| `Export-InstalledApps.ps1` | Win32 and AppX inventory CSV |
| `Install-Winget.ps1` | Install latest winget from GitHub releases |
| `Install-WindowsQualityUpdates.ps1` | Quality updates via PSWindowsUpdate |
| `Start-WindowsUpgradeFromIso.ps1` | In place upgrade from a lab ISO |
| `New-LocalLabUser.ps1` | Standard local user with SecureString prompt |
| `New-LabScanShare.ps1` | Scan folder, user and SMB share for a lab MFP |

None of these scripts store passwords. Prefer SecureString prompts or environment variables.
