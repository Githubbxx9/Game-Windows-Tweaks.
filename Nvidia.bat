@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Configuration
set "SOURCE_PATH=C:\Program Files\WindowsApps\NVIDIACorp.NVIDIAControlPanel_8.1.969.0_x64__56jybvy8sckqj"
set "DEST_DIR=C:\NVIDIA_ControlPanel_Win32"
set "EXE_NAME=nvcplui.exe"

echo ==========================================
echo NVIDIA Control Panel: UWP to Win32 Bridge
echo ==========================================

:: 1. Check Admin Rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator.
    pause
    exit /b 1
)

:: 2. Take Ownership of the Source Folder
:: Note: This modifies ACLs on a protected system folder.
echo [STEP 1] Taking ownership of WindowsApps NVIDIA folder...
takeown /F "%SOURCE_PATH%" /R /A /D Y >nul 2>&1
icacls "%SOURCE_PATH%" /grant Administrators:F /T /Q >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Failed to modify permissions. You may need to manually take ownership in Properties > Security.
)

:: 3. Create Destination Directory
echo [STEP 2] Creating Win32 directory...
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

:: 4. Copy Essential Files
echo [STEP 3] Copying executable and dependencies...
:: We copy the whole folder content to ensure DLL dependencies are met
xcopy "%SOURCE_PATH%\*" "%DEST_DIR%\" /E /I /H /Y >nul 2>&1

if not exist "%DEST_DIR%\%EXE_NAME%" (
    echo [ERROR] Failed to copy nvcplui.exe. Check if the source path version matches your installed version.
    echo Expected: %SOURCE_PATH%
    pause
    exit /b 1
)

:: 5. Register Context Menu (The "Win32" Feel)
echo [STEP 4] Registering Desktop Context Menu...
:: We create a registry key that invokes the copied executable directly.
:: This bypasses the UWP launcher and acts like the old Win32 app.

reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /ve /t REG_SZ /d "NVIDIA Control Panel" /f >nul
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /v "Icon" /t REG_SZ /d "%DEST_DIR%\nvcplui.exe" /f >nul
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel" /v "Position" /t REG_SZ /d "Bottom" /f >nul
reg add "HKCR\DesktopBackground\Shell\NVIDIAControlPanel\command" /ve /t REG_SZ /d "\"%DEST_DIR%\%EXE_NAME%\"" /f >nul

echo.
echo ==========================================
echo SUCCESS!
echo ==========================================
echo 1. The app has been copied to: %DEST_DIR%
echo 2. Right-click on your Desktop to see "NVIDIA Control Panel".
echo.
echo NOTE: If the panel opens but settings don't save, 
echo the UWP restriction is blocking write access. 
echo In that case, reinstalling the Store App is recommended.
pause   
