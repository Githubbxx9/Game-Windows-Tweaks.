<<<<<<< HEAD
@echo off
setlocal enabledelayedexpansion
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "BACKUP_DIR=C:\KairoBackUp"
set "BACKUP_FLAG=%BACKUP_DIR%\backup_done.flag"
set "BACKUP_REG=%BACKUP_DIR%\original_values.reg"
set "DELETE_LIST=%BACKUP_DIR%\delete_on_revert.txt"

if exist "%BACKUP_FLAG%" goto SHOW_MENU

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1

(
echo Windows Registry Editor Version 5.00
echo.
) > "%BACKUP_REG%"

if exist "%DELETE_LIST%" del /f /q "%DELETE_LIST%" >nul 2>&1

set "baseKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
set "foundSubkey="

for /L %%i in (0000,1,0020) do (
    if not defined foundSubkey (
        set "subkey=000%%i"
        set "subkey=!subkey:~-4!"
        reg query "%baseKey%\!subkey!" /v "DriverDesc" >nul 2>&1
        if !errorlevel! EQU 0 (
            for /f "tokens=3*" %%a in ('reg query "%baseKey%\!subkey!" /v "DriverDesc" 2^>nul') do (
                set "desc=%%a %%b"
                echo !desc! | find /I "NVIDIA" >nul
                if !errorlevel! EQU 0 (
                    set "foundSubkey=!subkey!"
                )
            )
        )
    )
)

if not defined foundSubkey goto BACKUP_DONE

:: --- GPU subkey values ---
set "gk=%baseKey%\!foundSubkey!"

call :CHECK_AND_BACKUP "%gk%" "DisableDynamicPstate"                        "00000001"
call :CHECK_AND_BACKUP "%gk%" "DisableAsyncPstates"                         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMPowerFeature"                              "54455555"
call :CHECK_AND_BACKUP "%gk%" "RMPowerFeature2"                             "05555555"
call :CHECK_AND_BACKUP "%gk%" "RMEnableOverclockingAllPstates"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMFspg"                                      "0000000F"
call :CHECK_AND_BACKUP "%gk%" "RMBlcg"                                      "11111111"
call :CHECK_AND_BACKUP "%gk%" "RMElcg"                                      "55555555"
call :CHECK_AND_BACKUP "%gk%" "RmElpg"                                      "00000FFF"
call :CHECK_AND_BACKUP "%gk%" "RMSlcg"                                      "0003FFFF"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvdecPgIdleThresholdUs"             "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvdecRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvencPgIdleThresholdUs"             "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvencRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvjpgRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidOfaPgIdleThresholdUs"               "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidOfaRpgIdleThresholdUs"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgOfaEntryThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvjpgEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvencEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvdecEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgGrEntryThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrGrRgIdleThresholdUs"                  "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsDifrCgIdleThresholdUs"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsDifrSwAsrIdleThresholdUs"           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsFbXbarPgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsLtcIdleThresholdUs"                 "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrGrIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrEiIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrDfprIdleThresholdUs"                  "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMDisableGpuASPMFlags"                      "00000003"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMDT"                             "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMAtLoad"                         "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMPublicBits"                     "00000000"
call :CHECK_AND_BACKUP "%gk%" "RmDisableHdcp22"                            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMHdcpKeyglobZero"                          "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMSkipHdcp22Init"                           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMHdcpOffload"                              "00000003"
call :CHECK_AND_BACKUP "%gk%" "RMNoECCFuseCheck"                           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMEnableL1ECC"                              "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableSMECC"                              "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMAssertOnEccErrors"                        "00000000"
call :CHECK_AND_BACKUP "%gk%" "RM1441072"                                  "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMGuestECCState"                            "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableSHMECC"                             "00000000"

:: --- GraphicsDrivers\Power ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power"      "EnableRuntimePowerManagement"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power"      "DisablePStateManagement"        "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler"  "EnablePreemption"               "00000001"

:: --- GraphicsDrivers\Scheduler ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AdjustWorkerThreadPriority"      "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AudioDgAutoBoostPriority"        "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AutoSyncToCPUPriority"           "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "DebugLargeSmoothenedDuration"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "ForegroundPriorityBoost"         "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "FrameServerAutoBoostPriority"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "QueuedPresentLimit"              "00000001"

:: --- GraphicsDrivers root ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableVersionMismatchCheck"         "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "EnableIgnoreWin32ProcessStatus"      "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "HwSchMode"                          "00000002"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "HwSchTreatExperimentalAsStable"      "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "TdrDebugMode"                       "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "TdrLevel"                           "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableBadDriverCheckForHwProtection"  "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableBoostedVSyncVirtualization"     "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableIndependentVidPnVSync"          "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableMultiSourceMPOCheck"            "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "EnableFbrValidation"                   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "KnownProcessBoostMode"                 "00000000"

:: --- Telemetry / nvlddmkm ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" "SendTelemetryData" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID44231" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID64640" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID66610" "00000000"
call :CHECK_AND_BACKUP "HKLM\Software\NVIDIA Corporation\NvControlPanel2\Client" "OptInOrOutPreference" "00000000"

:: --- NVIDIA Logging ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogDisableMasks"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogWarningEntries" "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogErrorEntries"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogEventEntries"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogEnableMasks"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogPagingEntries"  "00000000"

:BACKUP_DONE
echo backed up > "%BACKUP_FLAG%"
goto SHOW_MENU

:CHECK_AND_BACKUP
set "_key=%~1"
set "_val=%~2"
set "_expected=%~3"

for /f "tokens=2,3" %%X in ('reg query "%_key%" /v "%_val%" 2^>nul ^| findstr /i "REG_DWORD"') do (
    set "_type=%%X"
    set "_current=%%Y"
)

if not defined _current (
    echo [DELETE] %_key%  |||  %_val% >> "%DELETE_LIST%"
    set "_current="
    set "_type="
    goto :eof
)

set "_currentUP=%_current%"
set "_expectedUP=%_expected%"

set "_currentHEX=%_currentUP:~2%"
:PAD_LOOP
if "!_currentHEX:~7,1!"=="" set "_currentHEX=0!_currentHEX!" & goto PAD_LOOP

echo !_currentHEX! | findstr /i "^!_expectedUP!$" >nul 2>&1
if !errorlevel! EQU 0 (
    set "_current="
    set "_type="
    goto :eof
)

set "_regpath=%_key:HKLM\=HKEY_LOCAL_MACHINE\%"
set "_regpath=%_regpath:HKCU\=HKEY_CURRENT_USER\%"

(
echo [%_regpath%]
echo "%_val%"=dword:!_currentHEX!
echo.
) >> "%BACKUP_REG%"

set "_current="
set "_type="
set "_regpath="
set "_currentHEX="
goto :eof

:SHOW_MENU
mode con: cols=60 lines=12
echo.
timeout /t 1 /nobreak >nul
echo   %ESC%[38;5;214mMade by Kairo! %ESC%[38;5;240mv1.0%ESC%[0m
timeout /t 1 /nobreak >nul
echo   %ESC%[38;5;240mDisables powersaving/useless features, telemetry%ESC%[0m
echo   %ESC%[38;5;240mand imports an optimized NVIDIA Inspector Profile%ESC%[0m
timeout /t 1 /nobreak >nul
echo.
echo   %ESC%[38;5;240m-------------------------------------------------%ESC%[0m
echo   %ESC%[38;5;250m  Benchmark before ^& after to measure impact.%ESC%[0m
echo   %ESC%[38;5;250m  All changes are revertible %ESC%[0m
echo   %ESC%[38;5;240m-------------------------------------------------%ESC%[0m
echo.
timeout /t 3 /nobreak >nul
echo   Press %ESC%[38;5;82m[ANY KEY]%ESC%[0m to continue
pause >nul

cls
mode con: cols=110 lines=25
chcp 65001 >nul 2>&1
set c=[33m
set t=[0m
set w=[97m
set y=[0m
set u=[4m
set q=[0m

:MENU
echo.
echo.
echo %ESC%[38;5;214m %ESC%[38;5;214m %ESC%[38;5;214m▄▄▄   ▄▄▄%ESC%[0m
echo   %ESC%[38;5;214m███ ▄███▀       ▀▀%ESC%[0m
echo   %ESC%[38;5;214m███████    ▀▀█▄ ██  ████▄ ▄███▄ ▄█▀▀▀%ESC%[0m
echo   %ESC%[38;5;214m███▀███▄  ▄█▀██ ██  ██ ▀▀ ██ ██ ▀███▄%ESC%[0m
echo   %ESC%[38;5;214m███  ▀███ ▀█▄██ ██▄ ██    ▀███▀ ▄▄▄█▀%ESC%[0m
echo.
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo   %ESC%[38;5;82mNVIDIA TWEAKER  //  v1.0%ESC%[0m 
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo.
echo   %ESC%[38;5;250mSelect an option:%ESC%[0m
echo.
echo   %ESC%[38;5;82m  [1]  TWEAK   %ESC%[38;5;240m- Apply all optimizations%ESC%[0m
echo   %ESC%[38;5;196m  [2]  REVERT  %ESC%[38;5;240m- Undo changes%ESC%[0m
echo   %ESC%[38;5;240m  [3]  EXIT%ESC%[0m
echo.
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo.

set /p choice=   %ESC%[38;5;214m  NVIDIA Tweaker%ESC%[0m %ESC%[38;5;240m^>%ESC%[0m 

if "%choice%"=="1" goto TWEAK
if "%choice%"=="2" goto REVERT
if "%choice%"=="3" goto EXIT
goto INVALID

:TWEAK
  
  set "baseKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"

  echo Searching for NVIDIA GPU registry key...

  for /L %%i in (0000,1,0020) do (
    set "subkey=%%~i"
    set "subkey=000!subkey!"
    set "subkey=!subkey:~-4!"

    reg query "%baseKey%\!subkey!" /v "DriverDesc" 
    if !errorlevel! EQU 0 (
        for /f "tokens=3*" %%a in ('reg query "%baseKey%\!subkey!" /v "DriverDesc" 2^>nul') do (
            set "desc=%%a %%b"
            echo Found GPU: !desc!
            echo Checking if it's NVIDIA...

            echo !desc! | find /I "NVIDIA" >nul
            if !errorlevel! EQU 0 (
                echo NVIDIA GPU found at subkey: !subkey!
                echo Adding registry values...
				
				:: NVIDIA Driver Detector
                set "physx_present=0"
                set "hdaudio_present=0"
                if exist "%SystemRoot%\System32\PhysXDevice.dll" set "physx_present=1"
                reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "NVIDIA HD Audio" >nul 2>&1
                if not errorlevel 1 set "hdaudio_present=1"
 
                set "debloat_status=%ESC%[38;5;82mDebloated  — PhysX and HD Audio absent%ESC%[0m"
                if "!physx_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — PhysX present%ESC%[0m"
                if "!hdaudio_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — HD Audio present%ESC%[0m"
                if "!physx_present!"=="1" if "!hdaudio_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — PhysX and HD Audio present%ESC%[0m"
				
				echo !debloat_status!
				echo For optimal performance, debloat your driver.
				timeout /t 3 /nobreak >nul
				
				
				:: Powersaving
                reg add "%baseKey%\!subkey!" /v "DisableDynamicPstate" /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v "DisableAsyncPstates" /t REG_DWORD /d 1 /f
				reg add "%baseKey%\!subkey!" /v "RMPowerFeature" /t REG_DWORD /d 54455555 /f
                reg add "%baseKey%\!subkey!" /v "RMPowerFeature2" /t REG_DWORD /d 05555555 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableOverclockingAllPstates" /t REG_DWORD /d 1 /f 
				
				reg add "%baseKey%\!subkey!" /v "RMFspg" /t REG_DWORD /d 0000000F /f
				reg add "%baseKey%\!subkey!" /v "RMBlcg" /t REG_DWORD /d 11111111 /f
				reg add "%baseKey%\!subkey!" /v "RMElcg" /t REG_DWORD /d 55555555 /f
				reg add "%baseKey%\!subkey!" /v "RmElpg" /t REG_DWORD /d 00000FFF /f
				reg add "%baseKey%\!subkey!" /v "RMSlcg" /t REG_DWORD /d 0003ffff /f
				
                :: Power management thresholds

                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvdecPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvdecRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvencPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvencRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvjpgRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidOfaPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidOfaRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgOfaEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvjpgEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvencEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvdecEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgGrEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrGrRgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsDifrCgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsDifrSwAsrIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsFbXbarPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsLtcIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrGrIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrEiIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrDfprIdleThresholdUs /t REG_DWORD /d 1 /f

				:: ASPM
				reg add "%baseKey%\!subkey!" /v RMDisableGpuASPMFlags /t REG_DWORD /d 00000003 /f 
				reg add "%baseKey%\!subkey!" /v RMEnableASPMDT /t REG_DWORD /d 0 /f 
                reg add "%baseKey%\!subkey!" /v RMEnableASPMAtLoad /t REG_DWORD /d 0 /f 
                reg add "%baseKey%\!subkey!" /v RMEnableASPMPublicBits /t REG_DWORD /d 0 /f 
				
				:: HDCP
                reg add "%baseKey%\!subkey!" /v RmDisableHdcp22 /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMHdcpKeyglobZero /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMSkipHdcp22Init /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMHdcpOffload /t REG_DWORD /d 3 /f 
				
				:: ECC
				reg add "%baseKey%\!subkey!" /v "RMNoECCFuseCheck" /t REG_DWORD /d 1 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableL1ECC" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableSMECC" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMAssertOnEccErrors" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RM1441072" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMGuestECCState" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableSHMECC" /t REG_DWORD /d 0 /f
				
				:: GraphicsDrivers
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableRuntimePowerManagement" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DisablePStateManagement" /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AdjustWorkerThreadPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AudioDgAutoBoostPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AutoSyncToCPUPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v DebugLargeSmoothenedDuration /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v ForegroundPriorityBoost /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v FrameServerAutoBoostPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v QueuedPresentLimit /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableVersionMismatchCheck /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v EnableIgnoreWin32ProcessStatus /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v HwSchTreatExperimentalAsStable /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v TdrDebugMode /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v TdrLevel /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableBadDriverCheckForHwProtection /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableBoostedVSyncVirtualization /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableIndependentVidPnVSync /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableMultiSourceMPOCheck /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v EnableFbrValidation /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v KnownProcessBoostMode /t REG_DWORD /d 0 /f
				
				:: Telemetry
                reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" /v "SendTelemetryData" /t REG_DWORD /d 0 /f 
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f
                reg delete "HKLM\System\CurrentControlSet\Services\nvlddmkm\NvCamera" /f
                sc config NvTelemetryContainer start=disabled 

                For %%C in (Display.3DVision Display.Audio Ansel) Do (
                Rundll32.exe "C:\Program Files\NVIDIA Corporation\Installer2\InstallerCore\NVI2.dll",UninstallPackage %%C 
                )

                reg add "HKLM\Software\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f 
                reg Delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f 

                For %%i in (NvTmRep_CrashReport1 NvTmRep_CrashReport2 NvTmRep_CrashReport3 NvTmRep_CrashReport4) Do Schtasks /Change /Disable /Tn "%%i_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
                For %%i in (NvTmMon NvTmRep NvProfile NvNodeLauncher NvDriverUpdateCheckDaily NvBatteryBoostCheckOnLogon "NVIDIA GeForce Experience SelfUpdate") Do Schtasks /Change /Tn "%%i" /Disable 

                del /s /q "%SystemRoot%\System32\DriverStore\FileRepository\NvTelemetry64.dll"
                rd /s /q "%SystemRoot%\System32\DriverStore\FileRepository\nv*\NvCamera"
                del /s /q "%SystemRoot%\System32\DriverStore\FileRepository\nv*\Display.NvContainer\plugins\LocalSystem\_DisplayDriverRAS.dll"

                Takeown /F "C:\Windows\System32\drivers\NVIDIA Corporation" /R /D Y 
                Icacls "C:\Windows\System32\drivers\NVIDIA Corporation" /Grant %Username%:F /T 
                Rmdir /S /Q "C:\Windows\System32\drivers\NVIDIA Corporation" 
                cd /d "%systemdrive%\Windows\System32\DriverStore\FileRepository\" 
                dir NvTelemetry64.dll /a /b /s 
                del NvTelemetry64.dll /a /s 
                cd /d "%systemdrive%\Windows\System32\DriverStore\FileRepository\nv_dispig.inf_amd64_20ea7d0c917cde22" 
                del NvTelemetry64.dll /a /s 

                rd /s /q "%systemdrive%\Program Files\NVIDIA Corporation\Display.NvContainer\plugins\LocalSystem\DisplayDriverRAS" 
                rd /s /q "%systemdrive%\Program Files\NVIDIA Corporation\DisplayDriverRAS" 
                rd /s /q "%systemdrive%\ProgramData\NVIDIA Corporation\DisplayDriverRAS" 
				
				:: NVIDIA Logging
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogDisableMasks" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogWarningEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogErrorEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogEventEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogEnableMasks" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogPagingEntries" /t REG_DWORD /d 0 /f
				
				:: NVIDIA Profile Inspector
                curl -g -k -L -# -o "%temp%\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
                powershell -NoProfile Expand-Archive '%temp%\nvidiaProfileInspector.zip' -DestinationPath '%temp%\NvidiaProfileInspector\'
                curl -g -k -L -# -o "%temp%\NvidiaProfileInspector\Kairos_Profile.nip" "https://raw.githubusercontent.com/KairoZXT/NVIDIA-Tweaker/main/Kairos%20Profile.nip"
                start "" /wait "%temp%\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%temp%\NvidiaProfileInspector\Kairos_Profile.nip"
                timeout /t 3 /nobreak > NUL

                del /f /q "%temp%\nvidiaProfileInspector.zip"
                rmdir /s /q "%temp%\NvidiaProfileInspector\"

                echo.
                echo  Tweaks are completed
                timeout /t 3 /nobreak >nul
  
                exit 
            )
        )
    )
)

echo NVIDIA GPU not found.
goto MENU

:REVERT
cls
echo.
echo   %ESC%[38;5;214m  Reverting changes...%ESC%[0m
echo.

if not exist "%BACKUP_DIR%" (
    echo   %ESC%[38;5;196m[!] No backup found at %BACKUP_DIR%.%ESC%[0m
    echo   %ESC%[38;5;240m      Run the tweaker at least once to create a backup.%ESC%[0m
    echo.
    timeout /t 4 /nobreak >nul
    goto MENU
)

if exist "%BACKUP_REG%" (
    echo   %ESC%[38;5;250m  Restoring original registry values...%ESC%[0m
    regedit /s "%BACKUP_REG%"
    echo   %ESC%[38;5;82m  [OK] Original values restored.%ESC%[0m
) else (
    echo   %ESC%[38;5;240m  No changed values to restore.%ESC%[0m
)

if exist "%DELETE_LIST%" (
    echo   %ESC%[38;5;250m  Deleting values that were newly added...%ESC%[0m

    for /f "usebackq tokens=1,2,3 delims=|||" %%A in ("%DELETE_LIST%") do (
        set "_dkey=%%A"
        set "_dval=%%C"

        set "_dkey=!_dkey:[DELETE] =!"

        for /f "tokens=* delims= " %%T in ("!_dkey!") do set "_dkey=%%T"
        for /f "tokens=* delims= " %%T in ("!_dval!") do set "_dval=%%T"

        reg delete "!_dkey!" /v "!_dval!" /f >nul 2>&1
        if !errorlevel! EQU 0 (
            echo   %ESC%[38;5;82m  [DEL] !_dval!%ESC%[0m
        ) else (
            echo   %ESC%[38;5;240m  [--]  !_dval! ^(already gone^)%ESC%[0m
        )
    )
    echo   %ESC%[38;5;82m  [OK] Newly added values removed.%ESC%[0m
) else (
    echo   %ESC%[38;5;240m  No new values to delete.%ESC%[0m
)

del /f /q "%BACKUP_FLAG%" >nul 2>&1

echo.
echo   %ESC%[38;5;82m  Revert complete.%ESC%[0m
echo   %ESC%[38;5;240m  A fresh backup will be taken on next launch.%ESC%[0m
echo.
timeout /t 4 /nobreak >nul
goto MENU

:INVALID
echo.
echo   %ESC%[38;5;196m[!] Invalid option. Enter 1, 2, or 3.%ESC%[0m
echo.
timeout /t 2 /nobreak >nul
goto MENU
 
:EXIT
cls
echo.
echo   %ESC%[38;5;214mThanks for using Kairos NVIDIA Tweaker!%ESC%[0m
echo.
timeout /t 2 /nobreak >nul
=======
@echo off
setlocal enabledelayedexpansion
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "BACKUP_DIR=C:\KairoBackUp"
set "BACKUP_FLAG=%BACKUP_DIR%\backup_done.flag"
set "BACKUP_REG=%BACKUP_DIR%\original_values.reg"
set "DELETE_LIST=%BACKUP_DIR%\delete_on_revert.txt"

if exist "%BACKUP_FLAG%" goto SHOW_MENU

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1

(
echo Windows Registry Editor Version 5.00
echo.
) > "%BACKUP_REG%"

if exist "%DELETE_LIST%" del /f /q "%DELETE_LIST%" >nul 2>&1

set "baseKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
set "foundSubkey="

for /L %%i in (0000,1,0020) do (
    if not defined foundSubkey (
        set "subkey=000%%i"
        set "subkey=!subkey:~-4!"
        reg query "%baseKey%\!subkey!" /v "DriverDesc" >nul 2>&1
        if !errorlevel! EQU 0 (
            for /f "tokens=3*" %%a in ('reg query "%baseKey%\!subkey!" /v "DriverDesc" 2^>nul') do (
                set "desc=%%a %%b"
                echo !desc! | find /I "NVIDIA" >nul
                if !errorlevel! EQU 0 (
                    set "foundSubkey=!subkey!"
                )
            )
        )
    )
)

if not defined foundSubkey goto BACKUP_DONE

:: --- GPU subkey values ---
set "gk=%baseKey%\!foundSubkey!"

call :CHECK_AND_BACKUP "%gk%" "DisableDynamicPstate"                        "00000001"
call :CHECK_AND_BACKUP "%gk%" "DisableAsyncPstates"                         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMPowerFeature"                              "54455555"
call :CHECK_AND_BACKUP "%gk%" "RMPowerFeature2"                             "05555555"
call :CHECK_AND_BACKUP "%gk%" "RMEnableOverclockingAllPstates"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMFspg"                                      "0000000F"
call :CHECK_AND_BACKUP "%gk%" "RMBlcg"                                      "11111111"
call :CHECK_AND_BACKUP "%gk%" "RMElcg"                                      "55555555"
call :CHECK_AND_BACKUP "%gk%" "RmElpg"                                      "00000FFF"
call :CHECK_AND_BACKUP "%gk%" "RMSlcg"                                      "0003FFFF"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvdecPgIdleThresholdUs"             "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvdecRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvencPgIdleThresholdUs"             "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvencRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidNvjpgRpgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidOfaPgIdleThresholdUs"               "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrVidOfaRpgIdleThresholdUs"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgOfaEntryThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvjpgEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvencEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgNvdecEntryThresholdUs"         "00000001"
call :CHECK_AND_BACKUP "%gk%" "RmLpwrSeqFgpgGrEntryThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrGrRgIdleThresholdUs"                  "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsDifrCgIdleThresholdUs"              "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsDifrSwAsrIdleThresholdUs"           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsFbXbarPgIdleThresholdUs"            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrMsLtcIdleThresholdUs"                 "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrGrIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrEiIdleThresholdUs"                    "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMLpwrDfprIdleThresholdUs"                  "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMDisableGpuASPMFlags"                      "00000003"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMDT"                             "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMAtLoad"                         "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableASPMPublicBits"                     "00000000"
call :CHECK_AND_BACKUP "%gk%" "RmDisableHdcp22"                            "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMHdcpKeyglobZero"                          "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMSkipHdcp22Init"                           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMHdcpOffload"                              "00000003"
call :CHECK_AND_BACKUP "%gk%" "RMNoECCFuseCheck"                           "00000001"
call :CHECK_AND_BACKUP "%gk%" "RMEnableL1ECC"                              "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableSMECC"                              "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMAssertOnEccErrors"                        "00000000"
call :CHECK_AND_BACKUP "%gk%" "RM1441072"                                  "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMGuestECCState"                            "00000000"
call :CHECK_AND_BACKUP "%gk%" "RMEnableSHMECC"                             "00000000"

:: --- GraphicsDrivers\Power ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power"      "EnableRuntimePowerManagement"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power"      "DisablePStateManagement"        "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler"  "EnablePreemption"               "00000001"

:: --- GraphicsDrivers\Scheduler ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AdjustWorkerThreadPriority"      "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AudioDgAutoBoostPriority"        "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "AutoSyncToCPUPriority"           "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "DebugLargeSmoothenedDuration"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "ForegroundPriorityBoost"         "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "FrameServerAutoBoostPriority"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "QueuedPresentLimit"              "00000001"

:: --- GraphicsDrivers root ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableVersionMismatchCheck"         "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "EnableIgnoreWin32ProcessStatus"      "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "HwSchMode"                          "00000002"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "HwSchTreatExperimentalAsStable"      "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "TdrDebugMode"                       "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "TdrLevel"                           "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableBadDriverCheckForHwProtection"  "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableBoostedVSyncVirtualization"     "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableIndependentVidPnVSync"          "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "DisableMultiSourceMPOCheck"            "00000001"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "EnableFbrValidation"                   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" "KnownProcessBoostMode"                 "00000000"

:: --- Telemetry / nvlddmkm ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" "SendTelemetryData" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID44231" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID64640" "00000000"
call :CHECK_AND_BACKUP "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID66610" "00000000"
call :CHECK_AND_BACKUP "HKLM\Software\NVIDIA Corporation\NvControlPanel2\Client" "OptInOrOutPreference" "00000000"

:: --- NVIDIA Logging ---
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogDisableMasks"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogWarningEntries" "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogErrorEntries"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogEventEntries"   "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogEnableMasks"    "00000000"
call :CHECK_AND_BACKUP "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" "LogPagingEntries"  "00000000"

:BACKUP_DONE
echo backed up > "%BACKUP_FLAG%"
goto SHOW_MENU

:CHECK_AND_BACKUP
set "_key=%~1"
set "_val=%~2"
set "_expected=%~3"

for /f "tokens=2,3" %%X in ('reg query "%_key%" /v "%_val%" 2^>nul ^| findstr /i "REG_DWORD"') do (
    set "_type=%%X"
    set "_current=%%Y"
)

if not defined _current (
    echo [DELETE] %_key%  |||  %_val% >> "%DELETE_LIST%"
    set "_current="
    set "_type="
    goto :eof
)

set "_currentUP=%_current%"
set "_expectedUP=%_expected%"

set "_currentHEX=%_currentUP:~2%"
:PAD_LOOP
if "!_currentHEX:~7,1!"=="" set "_currentHEX=0!_currentHEX!" & goto PAD_LOOP

echo !_currentHEX! | findstr /i "^!_expectedUP!$" >nul 2>&1
if !errorlevel! EQU 0 (
    set "_current="
    set "_type="
    goto :eof
)

set "_regpath=%_key:HKLM\=HKEY_LOCAL_MACHINE\%"
set "_regpath=%_regpath:HKCU\=HKEY_CURRENT_USER\%"

(
echo [%_regpath%]
echo "%_val%"=dword:!_currentHEX!
echo.
) >> "%BACKUP_REG%"

set "_current="
set "_type="
set "_regpath="
set "_currentHEX="
goto :eof

:SHOW_MENU
mode con: cols=60 lines=12
echo.
timeout /t 1 /nobreak >nul
echo   %ESC%[38;5;214mMade by Kairo! %ESC%[38;5;240mv1.0%ESC%[0m
timeout /t 1 /nobreak >nul
echo   %ESC%[38;5;240mDisables powersaving/useless features, telemetry%ESC%[0m
echo   %ESC%[38;5;240mand imports an optimized NVIDIA Inspector Profile%ESC%[0m
timeout /t 1 /nobreak >nul
echo.
echo   %ESC%[38;5;240m-------------------------------------------------%ESC%[0m
echo   %ESC%[38;5;250m  Benchmark before ^& after to measure impact.%ESC%[0m
echo   %ESC%[38;5;250m  All changes are revertible %ESC%[0m
echo   %ESC%[38;5;240m-------------------------------------------------%ESC%[0m
echo.
timeout /t 3 /nobreak >nul
echo   Press %ESC%[38;5;82m[ANY KEY]%ESC%[0m to continue
pause >nul

cls
mode con: cols=110 lines=25
chcp 65001 >nul 2>&1
set c=[33m
set t=[0m
set w=[97m
set y=[0m
set u=[4m
set q=[0m

:MENU
echo.
echo.
echo %ESC%[38;5;214m %ESC%[38;5;214m %ESC%[38;5;214m▄▄▄   ▄▄▄%ESC%[0m
echo   %ESC%[38;5;214m███ ▄███▀       ▀▀%ESC%[0m
echo   %ESC%[38;5;214m███████    ▀▀█▄ ██  ████▄ ▄███▄ ▄█▀▀▀%ESC%[0m
echo   %ESC%[38;5;214m███▀███▄  ▄█▀██ ██  ██ ▀▀ ██ ██ ▀███▄%ESC%[0m
echo   %ESC%[38;5;214m███  ▀███ ▀█▄██ ██▄ ██    ▀███▀ ▄▄▄█▀%ESC%[0m
echo.
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo   %ESC%[38;5;82mNVIDIA TWEAKER  //  v1.0%ESC%[0m 
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo.
echo   %ESC%[38;5;250mSelect an option:%ESC%[0m
echo.
echo   %ESC%[38;5;82m  [1]  TWEAK   %ESC%[38;5;240m- Apply all optimizations%ESC%[0m
echo   %ESC%[38;5;196m  [2]  REVERT  %ESC%[38;5;240m- Undo changes%ESC%[0m
echo   %ESC%[38;5;240m  [3]  EXIT%ESC%[0m
echo.
echo   %ESC%[38;5;240m-------------------------------------------------------------%ESC%[0m
echo.

set /p choice=   %ESC%[38;5;214m  NVIDIA Tweaker%ESC%[0m %ESC%[38;5;240m^>%ESC%[0m 

if "%choice%"=="1" goto TWEAK
if "%choice%"=="2" goto REVERT
if "%choice%"=="3" goto EXIT
goto INVALID

:TWEAK
  
  set "baseKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"

  echo Searching for NVIDIA GPU registry key...

  for /L %%i in (0000,1,0020) do (
    set "subkey=%%~i"
    set "subkey=000!subkey!"
    set "subkey=!subkey:~-4!"

    reg query "%baseKey%\!subkey!" /v "DriverDesc" 
    if !errorlevel! EQU 0 (
        for /f "tokens=3*" %%a in ('reg query "%baseKey%\!subkey!" /v "DriverDesc" 2^>nul') do (
            set "desc=%%a %%b"
            echo Found GPU: !desc!
            echo Checking if it's NVIDIA...

            echo !desc! | find /I "NVIDIA" >nul
            if !errorlevel! EQU 0 (
                echo NVIDIA GPU found at subkey: !subkey!
                echo Adding registry values...
				
				:: NVIDIA Driver Detector
                set "physx_present=0"
                set "hdaudio_present=0"
                if exist "%SystemRoot%\System32\PhysXDevice.dll" set "physx_present=1"
                reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "NVIDIA HD Audio" >nul 2>&1
                if not errorlevel 1 set "hdaudio_present=1"
 
                set "debloat_status=%ESC%[38;5;82mDebloated  — PhysX and HD Audio absent%ESC%[0m"
                if "!physx_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — PhysX present%ESC%[0m"
                if "!hdaudio_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — HD Audio present%ESC%[0m"
                if "!physx_present!"=="1" if "!hdaudio_present!"=="1" set "debloat_status=%ESC%[38;5;196mNot debloated  — PhysX and HD Audio present%ESC%[0m"
				
				echo !debloat_status!
				echo For optimal performance, debloat your driver.
				timeout /t 3 /nobreak >nul
				
				
				:: Powersaving
                reg add "%baseKey%\!subkey!" /v "DisableDynamicPstate" /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v "DisableAsyncPstates" /t REG_DWORD /d 1 /f
				reg add "%baseKey%\!subkey!" /v "RMPowerFeature" /t REG_DWORD /d 54455555 /f
                reg add "%baseKey%\!subkey!" /v "RMPowerFeature2" /t REG_DWORD /d 05555555 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableOverclockingAllPstates" /t REG_DWORD /d 1 /f 
				
				reg add "%baseKey%\!subkey!" /v "RMFspg" /t REG_DWORD /d 0000000F /f
				reg add "%baseKey%\!subkey!" /v "RMBlcg" /t REG_DWORD /d 11111111 /f
				reg add "%baseKey%\!subkey!" /v "RMElcg" /t REG_DWORD /d 55555555 /f
				reg add "%baseKey%\!subkey!" /v "RmElpg" /t REG_DWORD /d 00000FFF /f
				reg add "%baseKey%\!subkey!" /v "RMSlcg" /t REG_DWORD /d 0003ffff /f
				
                :: Power management thresholds

                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvdecPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvdecRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvencPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvencRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidNvjpgRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidOfaPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrVidOfaRpgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgOfaEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvjpgEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvencEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgNvdecEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RmLpwrSeqFgpgGrEntryThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrGrRgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsDifrCgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsDifrSwAsrIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsFbXbarPgIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrMsLtcIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrGrIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrEiIdleThresholdUs /t REG_DWORD /d 1 /f
                reg add "%baseKey%\!subkey!" /v RMLpwrDfprIdleThresholdUs /t REG_DWORD /d 1 /f

				:: ASPM
				reg add "%baseKey%\!subkey!" /v RMDisableGpuASPMFlags /t REG_DWORD /d 00000003 /f 
				reg add "%baseKey%\!subkey!" /v RMEnableASPMDT /t REG_DWORD /d 0 /f 
                reg add "%baseKey%\!subkey!" /v RMEnableASPMAtLoad /t REG_DWORD /d 0 /f 
                reg add "%baseKey%\!subkey!" /v RMEnableASPMPublicBits /t REG_DWORD /d 0 /f 
				
				:: HDCP
                reg add "%baseKey%\!subkey!" /v RmDisableHdcp22 /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMHdcpKeyglobZero /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMSkipHdcp22Init /t REG_DWORD /d 1 /f 
                reg add "%baseKey%\!subkey!" /v RMHdcpOffload /t REG_DWORD /d 3 /f 
				
				:: ECC
				reg add "%baseKey%\!subkey!" /v "RMNoECCFuseCheck" /t REG_DWORD /d 1 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableL1ECC" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableSMECC" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMAssertOnEccErrors" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RM1441072" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMGuestECCState" /t REG_DWORD /d 0 /f
				reg add "%baseKey%\!subkey!" /v "RMEnableSHMECC" /t REG_DWORD /d 0 /f
				
				:: GraphicsDrivers
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "EnableRuntimePowerManagement" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "DisablePStateManagement" /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AdjustWorkerThreadPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AudioDgAutoBoostPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v AutoSyncToCPUPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v DebugLargeSmoothenedDuration /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v ForegroundPriorityBoost /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v FrameServerAutoBoostPriority /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v QueuedPresentLimit /t REG_DWORD /d 1 /f
				reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableVersionMismatchCheck /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v EnableIgnoreWin32ProcessStatus /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v HwSchTreatExperimentalAsStable /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v TdrDebugMode /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v TdrLevel /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableBadDriverCheckForHwProtection /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableBoostedVSyncVirtualization /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableIndependentVidPnVSync /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v DisableMultiSourceMPOCheck /t REG_DWORD /d 1 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v EnableFbrValidation /t REG_DWORD /d 0 /f
                reg add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers" /v KnownProcessBoostMode /t REG_DWORD /d 0 /f
				
				:: Telemetry
                reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" /v "SendTelemetryData" /t REG_DWORD /d 0 /f 
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID44231 /t REG_DWORD /d 0 /f
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID64640 /t REG_DWORD /d 0 /f
                reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v EnableRID66610 /t REG_DWORD /d 0 /f
                reg delete "HKLM\System\CurrentControlSet\Services\nvlddmkm\NvCamera" /f
                sc config NvTelemetryContainer start=disabled 

                For %%C in (Display.3DVision Display.Audio Ansel) Do (
                Rundll32.exe "C:\Program Files\NVIDIA Corporation\Installer2\InstallerCore\NVI2.dll",UninstallPackage %%C 
                )

                reg add "HKLM\Software\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f 
                reg Delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f 

                For %%i in (NvTmRep_CrashReport1 NvTmRep_CrashReport2 NvTmRep_CrashReport3 NvTmRep_CrashReport4) Do Schtasks /Change /Disable /Tn "%%i_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 
                For %%i in (NvTmMon NvTmRep NvProfile NvNodeLauncher NvDriverUpdateCheckDaily NvBatteryBoostCheckOnLogon "NVIDIA GeForce Experience SelfUpdate") Do Schtasks /Change /Tn "%%i" /Disable 

                del /s /q "%SystemRoot%\System32\DriverStore\FileRepository\NvTelemetry64.dll"
                rd /s /q "%SystemRoot%\System32\DriverStore\FileRepository\nv*\NvCamera"
                del /s /q "%SystemRoot%\System32\DriverStore\FileRepository\nv*\Display.NvContainer\plugins\LocalSystem\_DisplayDriverRAS.dll"

                Takeown /F "C:\Windows\System32\drivers\NVIDIA Corporation" /R /D Y 
                Icacls "C:\Windows\System32\drivers\NVIDIA Corporation" /Grant %Username%:F /T 
                Rmdir /S /Q "C:\Windows\System32\drivers\NVIDIA Corporation" 
                cd /d "%systemdrive%\Windows\System32\DriverStore\FileRepository\" 
                dir NvTelemetry64.dll /a /b /s 
                del NvTelemetry64.dll /a /s 
                cd /d "%systemdrive%\Windows\System32\DriverStore\FileRepository\nv_dispig.inf_amd64_20ea7d0c917cde22" 
                del NvTelemetry64.dll /a /s 

                rd /s /q "%systemdrive%\Program Files\NVIDIA Corporation\Display.NvContainer\plugins\LocalSystem\DisplayDriverRAS" 
                rd /s /q "%systemdrive%\Program Files\NVIDIA Corporation\DisplayDriverRAS" 
                rd /s /q "%systemdrive%\ProgramData\NVIDIA Corporation\DisplayDriverRAS" 
				
				:: NVIDIA Logging
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogDisableMasks" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogWarningEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogErrorEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogEventEntries" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogEnableMasks" /t REG_DWORD /d 0 /f
				reg add "HKLM\SYSTEM\ControlSet001\Services\nvlddmkm\Parameters" /v "LogPagingEntries" /t REG_DWORD /d 0 /f
				
				:: NVIDIA Profile Inspector
                curl -g -k -L -# -o "%temp%\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
                powershell -NoProfile Expand-Archive '%temp%\nvidiaProfileInspector.zip' -DestinationPath '%temp%\NvidiaProfileInspector\'
                curl -g -k -L -# -o "%temp%\NvidiaProfileInspector\Kairos_Profile.nip" "https://raw.githubusercontent.com/KairoZXT/NVIDIA-Tweaker/main/Kairos%20Profile.nip"
                start "" /wait "%temp%\NvidiaProfileInspector\nvidiaProfileInspector.exe" "%temp%\NvidiaProfileInspector\Kairos_Profile.nip"
                timeout /t 3 /nobreak > NUL

                del /f /q "%temp%\nvidiaProfileInspector.zip"
                rmdir /s /q "%temp%\NvidiaProfileInspector\"

                echo.
                echo  Tweaks are completed
                timeout /t 3 /nobreak >nul
  
                exit 
            )
        )
    )
)

echo NVIDIA GPU not found.
goto MENU

:REVERT
cls
echo.
echo   %ESC%[38;5;214m  Reverting changes...%ESC%[0m
echo.

if not exist "%BACKUP_DIR%" (
    echo   %ESC%[38;5;196m[!] No backup found at %BACKUP_DIR%.%ESC%[0m
    echo   %ESC%[38;5;240m      Run the tweaker at least once to create a backup.%ESC%[0m
    echo.
    timeout /t 4 /nobreak >nul
    goto MENU
)

if exist "%BACKUP_REG%" (
    echo   %ESC%[38;5;250m  Restoring original registry values...%ESC%[0m
    regedit /s "%BACKUP_REG%"
    echo   %ESC%[38;5;82m  [OK] Original values restored.%ESC%[0m
) else (
    echo   %ESC%[38;5;240m  No changed values to restore.%ESC%[0m
)

if exist "%DELETE_LIST%" (
    echo   %ESC%[38;5;250m  Deleting values that were newly added...%ESC%[0m

    for /f "usebackq tokens=1,2,3 delims=|||" %%A in ("%DELETE_LIST%") do (
        set "_dkey=%%A"
        set "_dval=%%C"

        set "_dkey=!_dkey:[DELETE] =!"

        for /f "tokens=* delims= " %%T in ("!_dkey!") do set "_dkey=%%T"
        for /f "tokens=* delims= " %%T in ("!_dval!") do set "_dval=%%T"

        reg delete "!_dkey!" /v "!_dval!" /f >nul 2>&1
        if !errorlevel! EQU 0 (
            echo   %ESC%[38;5;82m  [DEL] !_dval!%ESC%[0m
        ) else (
            echo   %ESC%[38;5;240m  [--]  !_dval! ^(already gone^)%ESC%[0m
        )
    )
    echo   %ESC%[38;5;82m  [OK] Newly added values removed.%ESC%[0m
) else (
    echo   %ESC%[38;5;240m  No new values to delete.%ESC%[0m
)

del /f /q "%BACKUP_FLAG%" >nul 2>&1

echo.
echo   %ESC%[38;5;82m  Revert complete.%ESC%[0m
echo   %ESC%[38;5;240m  A fresh backup will be taken on next launch.%ESC%[0m
echo.
timeout /t 4 /nobreak >nul
goto MENU

:INVALID
echo.
echo   %ESC%[38;5;196m[!] Invalid option. Enter 1, 2, or 3.%ESC%[0m
echo.
timeout /t 2 /nobreak >nul
goto MENU
 
:EXIT
cls
echo.
echo   %ESC%[38;5;214mThanks for using Kairos NVIDIA Tweaker!%ESC%[0m
echo.
timeout /t 2 /nobreak >nul
>>>>>>> ea82be7 (Initial commit)
exit