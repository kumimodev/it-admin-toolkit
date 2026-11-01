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

.EXAMPLE
  .\Reset-Winsock.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = 'Stop'

if (-not $PSCmdlet.ShouldProcess('Winsock catalogue', 'Reset with netsh')) {
    return
}

try {
    Write-Verbose 'Resetting Winsock catalogue...'
    $proc = Start-Process -FilePath 'netsh.exe' -ArgumentList @('winsock', 'reset') -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        Write-Error "netsh winsock reset exited with code $($proc.ExitCode)"
        exit $proc.ExitCode
    }
    Write-Output 'Winsock reset completed. Reboot the device before you rely on networking.'
    exit 0
}
catch {
    Write-Error "Winsock reset failed: $($_.Exception.Message)"
    exit 1
}
