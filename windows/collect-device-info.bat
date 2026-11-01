:: Collect username, hostname, and BIOS serial for lab enrolment notes.
:: Output: %USERPROFILE%\Downloads\ForInTuneEnrolment\UsernameHostnameSN_%USERNAME%.txt

@echo Gathering device info...

@md "%USERPROFILE%\Downloads\ForInTuneEnrolment" 2> nul

@(
	echo Domain\Username
	whoami
	echo -----
	echo Hostname
	hostname
	echo -----
	wmic bios get serialnumber | find /v ""
) > "%USERPROFILE%\Downloads\ForInTuneEnrolment\UsernameHostnameSN_%USERNAME%.txt"

@echo Info exported to %USERPROFILE%\Downloads\ForInTuneEnrolment\
@pause
