@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Configuration
set "OUTPUT_DIR=%APPDATA%\NVIDIA_ControlPanel_Standalone"
set "PACKAGE_NAME=NVIDIACorp.NVIDIAControlPanel"

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit /b 1
)

echo Locating NVIDIA Control Panel UWP package...

:: Use PowerShell to find the install location and copy files
:: This bypasses the need for 7-Zip and handles WindowsApps permissions
powershell -Command ^
    "$pkg = Get-AppxPackage -Name '%PACKAGE_NAME%'; ^
    if ($pkg) { ^
        $src = $pkg.InstallLocation; ^
        $dest = '%OUTPUT_DIR%'; ^
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }; ^
        New-Item -ItemType Directory -Force -Path $dest | Out-Null; ^
        Copy-Item -Path ($src + '\*') -Destination $dest -Recurse -Force; ^
        Write-Host ('Files copied successfully to: ' + $dest) ^
    } else { ^
        Write-Error 'NVIDIA Control Panel package not found. Please install it from the Microsoft Store.'; ^
        exit 1 ^
    }"

if %errorLevel% neq 0 (
    echo Failed to locate or copy NVIDIA Control Panel files.
    echo Ensure the NVIDIA Control Panel is installed via the Microsoft Store.
    pause
    exit /b 1
)

:: Verify the executable exists
if not exist "%OUTPUT_DIR%\nvcplui.exe" (
    echo Critical Error: nvcplui.exe not found in the copied files.
    pause
    exit /b 1
)

echo Creating desktop shortcut...
:: Create shortcut using PowerShell within the batch file
powershell -Command ^
    "$WshShell = New-Object -ComObject WScript.Shell; ^
    $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\NVIDIA Control Panel (Win32).lnk'); ^
    $Shortcut.TargetPath = '%OUTPUT_DIR%\nvcplui.exe'; ^
    $Shortcut.WorkingDirectory = '%OUTPUT_DIR%'; ^
    $Shortcut.Save()"

echo Adding to desktop context menu...
:: Add to right-click menu on desktop background
reg delete "HKCR\Directory\Background\shell\NVCPLWin32" /f >nul 2>&1
reg add "HKCR\Directory\Background\shell\NVCPLWin32" /v "MUIVerb" /t REG_SZ /d "NVIDIA Control Panel" /f
reg add "HKCR\Directory\Background\shell\NVCPLWin32" /v "Icon" /t REG_SZ /d "%OUTPUT_DIR%\nvcplui.exe" /f
reg add "HKCR\Directory\Background\shell\NVCPLWin32\command" /ve /t REG_SZ /d "\"%OUTPUT_DIR%\nvcplui.exe\"" /f

echo.
echo Done! NVIDIA Control Panel has been extracted to a standalone folder.
echo You can launch it from your Desktop shortcut or by right-clicking the desktop.
ENDLOCAL
pause   
