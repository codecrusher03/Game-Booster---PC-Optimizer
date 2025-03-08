@echo off
setlocal enabledelayedexpansion

:: Enable ANSI color support
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Color definitions
set "ESC="
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

:: Configuration
set "CONFIG_FILE=Config.cfg"
set "VERSION=2.6.0"
set "LOG_FILE=GBooster.log"

:: Initialization
if not exist "%CONFIG_FILE%" (
    echo %YELLOW%Creating default configuration...%RESET%
    (
        echo [Settings]
        echo SERVICES_DISABLE=SysMain,WSearch,DiagTrack,dmwappushservice,XboxGipSvc,XboxNetApiSvc
        echo CLEANUP_PATHS=%%SystemDrive%%\Windows\Temp,%%USERPROFILE%%\AppData\Local\Temp
        echo NETWORK_PROFILE=Gaming
    ) > "%CONFIG_FILE%"
)

:: Admin Check
fltmc >nul 2>&1 || (
    echo %YELLOW%Requesting administrator privileges...%RESET%
    timeout /t 3 >nul
    powershell start -verb runas '%~f0' %*
    exit /b
)

:main
cls
echo %CYAN%
echo --------------------------------------------------
echo     _______   ______    _______  ___      ______  
echo    / _____ \ /  __  \  / _____/ /   \    / ____ \ 
echo   / /____/ //  /  \  \/ /____  / /\ \  / /___/ / 
echo  / _____  //  /    \  \____  \/ /__\ \/ /  ____/ 
echo / /____/ //  /____  /_____/  /  ____  / /__/___  
echo \_______//________/\_______/__/    /_/\_______/  
echo --------------------------------------------------
echo %YELLOW%  Ultimate Windows Optimization Suite v%VERSION%%RESET%
echo %CYAN%--------------------------------------------------%RESET%
echo %GREEN%[1] Apply Gaming Optimizations
echo [2] Restore Default Settings
echo [3] System Diagnostics
echo [4] Update Optimizer
echo [5] Exit
echo %CYAN%--------------------------------------------------%RESET%

set /p "choice=%YELLOW%Select operation [1-5]: %RESET%"

if "%choice%"=="1" goto Optimize
if "%choice%"=="2" goto Restore
if "%choice%"=="3" goto Diagnostics
if "%choice%"=="4" goto Update
if "%choice%"=="5" exit
goto main

:Optimize
call :Logger "=== Starting Optimization Process ==="
call :LoadConfig
call :SystemCheck
call :PowerSettings
call :ServiceControl disable
call :NetworkBoost
call :GPUTweaks
call :SystemTweaks
call :Cleanup
call :Logger "=== Optimization Complete ==="
echo %CYAN%--------------------------------------------------%RESET%
echo %GREEN%Optimization successful!%RESET% Check %YELLOW%%LOG_FILE%%%RESET% for details
timeout /t 5 >nul
goto main

:Restore
call :Logger "=== Starting Restoration Process ==="
call :LoadConfig
call :PowerRestore
call :ServiceControl enable
call :NetworkReset
call :GPURestore
call :SystemRestore
call :Logger "=== Restoration Complete ==="
echo %CYAN%--------------------------------------------------%RESET%
echo %GREEN%System settings restored successfully%RESET%
timeout /t 5 >nul
goto main

:Diagnostics
echo %CYAN%[System Information]%RESET%
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo %CYAN%[CPU Information]%RESET%
wmic cpu get name
echo %CYAN%[Memory Information]%RESET%
wmic memorychip get capacity
pause
goto main

:Update
echo %YELLOW%Checking for updates...%RESET%
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/user/repo/main/GBooster.bat' -OutFile 'GBooster.bat'"
echo %GREEN%Update completed!%RESET%
timeout /t 3 >nul
goto main

:: ========== COLORIZED MODULES ==========

:Logger
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
if "%~1" == "=== Starting Optimization Process ===" (
    echo %MAGENTA%%~1%RESET%
) else if "%~1" == "=== Optimization Complete ===" (
    echo %GREEN%%~1%RESET%
) else if "%~1" == "=== Starting Restoration Process ===" (
    echo %MAGENTA%%~1%RESET%
) else if "%~1" == "=== Restoration Complete ===" (
    echo %GREEN%%~1%RESET%
) else (
    echo %CYAN%%~1%RESET%
)
exit /b

:LoadConfig
for /f "tokens=1* delims==" %%a in (%CONFIG_FILE%) do (
    set "%%a=%%b"
)
exit /b

:SystemCheck
wmic os get osarchitecture | find "64" >nul
if %errorlevel% equ 0 (
    set ARCH=64
) else (
    set ARCH=32
)
call :Logger "System Check: %ARCH%-bit architecture detected"
exit /b

:PowerSettings
call :Logger "Applying Ultimate Performance Power Plan"
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
exit /b

:ServiceControl
for %%s in (%SERVICES_DISABLE%) do (
    sc stop "%%s" >nul 2>&1
    sc config "%%s" start=%~1 >nul 2>&1
    call :Logger "Service: %%s set to %~1"
)
exit /b

:NetworkBoost
call :Logger "Optimizing Network Stack"
netsh int tcp set global autotuninglevel=highlyrestricted >nul
netsh int tcp set global ecncapability=disabled >nul
netsh int tcp set global timestamps=disabled >nul
exit /b

:GPUTweaks
call :Logger "Applying GPU Performance Tweaks"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Software\Microsoft\DirectX\UserGlobalSettings" /v SwapEffectUpgradeEnable /t REG_DWORD /d 1 /f >nul
exit /b

:SystemTweaks
call :Logger "Applying System Performance Tweaks"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "10" /f >nul
exit /b

:Cleanup
call :Logger "Cleaning System Junk"
del /f /s /q %SystemDrive%\*.tmp >nul 2>&1
del /f /s /q %SystemDrive%\*.log >nul 2>&1
ipconfig /flushdns >nul
exit /b

:PowerRestore
call :Logger "Restoring Default Power Plan"
powercfg -setactive SCHEME_BALANCED >nul
exit /b

:NetworkReset
call :Logger "Resetting Network Settings"
netsh int tcp reset >nul
netsh winsock reset >nul
exit /b

:GPURestore
call :Logger "Restoring GPU Settings"
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /f >nul 2>&1
exit /b

:SystemRestore
call :Logger "Restoring System Defaults"
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /f >nul 2>&1
exit /b