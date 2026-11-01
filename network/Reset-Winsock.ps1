#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Resets the Winsock catalogue on a lab Windows device.

.DESCRIPTION
  Runs netsh winsock reset. This does not clear saved Wi Fi profiles or credentials.
  Reboot the device after it completes.

.EXAMPLE
  .\Reset-Winsock.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Write-Verbose 'Resetting Winsock catalogue...'
$p = Start-Process -FilePath 'netsh.exe' -ArgumentList @('winsock', 'reset') -Wait -PassThru -NoNewWindow
if ($p.ExitCode -ne 0) {
    Write-Error "netsh winsock reset exited with code $($p.ExitCode)"
    exit $p.ExitCode
}
Write-Output 'Winsock reset completed. Reboot the device before you rely on networking.'
exit 0
