@echo off
setlocal enabledelayedexpansion

:: Configuration
set "CONFIG_FILE=Config.cfg"
set "VERSION=2.5.2"
set "LOG_FILE=GBooster.log"

:: Initialize Config File
if not exist "%CONFIG_FILE%" (
    echo Creating default configuration...
    (
        echo [Settings]
        echo SERVICES_DISABLE=SysMain,WSearch,DiagTrack,dmwappushservice,XboxGipSvc,XboxNetApiSvc
        echo CLEANUP_PATHS=%%SystemDrive%%\Windows\Temp,%%USERPROFILE%%\AppData\Local\Temp
        echo NETWORK_PROFILE=Gaming
    ) > "%CONFIG_FILE%"
)

:: Admin Check
fltmc >nul 2>&1 || (
    echo Requesting administrator privileges...
    timeout /t 3 >nul
    powershell start -verb runas '%~f0' %*
    exit /b
)

:main
cls
echo --------------------------------------------------
echo     _______   ______    _______  ___      ______  
echo    / _____ \ /  __  \  / _____/ /   \    / ____ \ 
echo   / /____/ //  /  \  \/ /____  / /\ \  / /___/ / 
echo  / _____  //  /    \  \____  \/ /__\ \/ /  ____/ 
echo / /____/ //  /____  /_____/  /  ____  / /__/___  
echo \_______//________/\_______/__/    /_/\_______/  
echo --------------------------------------------------
echo       Ultimate Windows Optimization Suite v%VERSION%
echo --------------------------------------------------
echo [1] Apply Gaming Optimizations
echo [2] Restore Default Settings
echo [3] System Diagnostics
echo [4] Update Optimizer
echo [5] Exit
echo --------------------------------------------------

set /p choice="Select operation [1-5]: "

if "%choice%"=="1" goto Optimize
if "%choice%"=="2" goto Restore
if "%choice%"=="3" goto Diagnostics
if "%choice%"=="4" goto Update
if "%choice%"=="5" exit
goto main

:: Rest of the script remains the same...

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
echo --------------------------------------------------
echo Optimization successful! Check %LOG_FILE% for details
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
echo --------------------------------------------------
echo System settings restored successfully
timeout /t 5 >nul
goto main

:Diagnostics
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
wmic cpu get name
wmic memorychip get capacity
pause
goto main

:Update
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/user/repo/main/GBooster.bat' -OutFile 'GBooster.bat'"
echo Update completed!
timeout /t 3 >nul
goto main

:: ========== MODULES ==========

:Logger
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
echo %~1
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