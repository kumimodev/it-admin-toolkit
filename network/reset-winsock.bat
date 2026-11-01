:: Reset the Winsock catalogue. This does not clear saved Wi Fi profiles or credentials.
:: Reboot the device after it completes.

@echo Resetting Winsock...
@netsh winsock reset
@echo Done. Please reboot.
@pause
