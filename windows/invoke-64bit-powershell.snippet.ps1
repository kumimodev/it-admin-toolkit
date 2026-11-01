# Place this block at the top of a Win32 script that must run as 64 bit PowerShell.
# Assumes the script has no parameters, or that you forward them yourself.

If ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64') {
    Try {
        & "$ENV:WINDIR\SysNative\WindowsPowerShell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}
