@echo off
echo Running system diagnostics...
echo ------------------------------
echo [System Information]
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.
echo [CPU Information]
wmic cpu get name
echo.
echo [Memory Information]
wmic memorychip get capacity
echo.
echo [Disk Information]
wmic diskdrive get model,size
echo.
pause