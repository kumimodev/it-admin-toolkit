@echo off
REM Flushes the local DNS resolver cache. Run from an elevated Command Prompt when name resolution sticks.
ipconfig /flushdns
echo Done.
pause
