@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Configuration
set "EXTRACT_DIR=%TEMP%\NVCPL_Extract"
set "NVCPLUIR_DLL=nvcpluir.dll"
set "OUTPUT_DIR=%APPDATA%\NVIDIA_ControlPanel"
set "STAGING_DIR=%TEMP%\NVCPL_Staging"

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit /b 1
)

echo Locating NVIDIA Control Panel APPX package...
:: Use PowerShell to find the package path reliably, bypassing WindowsApps permission restrictions
for /f "delims=" %%i in ('powershell -NoProfile -Command "$pkg = Get-AppxPackage -Name 'NVIDIACorp.NVIDIAControlPanel'; if ($pkg) { Write-Output $pkg.InstallLocation } else { Write-Output 'NOT_FOUND' }"') do (
    set "APPX_SOURCE_PATH=%%i"
)

if "!APPX_SOURCE_PATH!" == "NOT_FOUND" (
    echo Error: NVIDIA Control Panel APPX package not found.
    echo Please ensure it is installed via the Microsoft Store.
    pause
    exit /b 1
)

echo Found package at: !APPX_SOURCE_PATH!

:: Since we cannot read directly from WindowsApps easily due to TrustedInstaller permissions,
:: we copy the entire package folder to a staging area first.
echo Copying package to staging area to bypass permission restrictions...
if exist "%STAGING_DIR%" rmdir /s /q "%STAGING_DIR%"
mkdir "%STAGING_DIR%"

:: Use Robocopy with backup mode to bypass some permission issues, or standard copy if ACLs allow read
:: Note: If this fails, the user must manually take ownership of the WindowsApps folder entry.
robocopy "!APPX_SOURCE_PATH!" "%STAGING_DIR%" /E /NFL /NDL /NJH /NJS >nul
if !errorLevel! geq 8 (
    echo Failed to copy files from WindowsApps. Access Denied.
    echo Attempting to find the .appx bundle file directly...
    :: Fallback: Look for .msixbundle or .appxbundle inside the source if robocopy failed on folders
    for %%f in ("!APPX_SOURCE_PATH!"\*.appxbundle "*.msixbundle") do (
        if exist "%%f" (
            set "APPX_BUNDLE=%%f"
            goto :FoundBundle
        )
    )
    echo Critical Error: Unable to access package files. You may need to take ownership of the folder in C:\Program Files\WindowsApps manually.
    pause
    exit /b 1
)
:FoundBundle

:: Check if 7-Zip is available
set "SEVEN_ZIP_FOUND=0"
if exist "C:\Program Files\7-Zip\7z.exe" (
    set "SEVEN_ZIP_PATH=C:\Program Files\7-Zip\7z.exe"
    set "SEVEN_ZIP_FOUND=1"
) else if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
    set "SEVEN_ZIP_PATH=C:\Program Files (x86)\7-Zip\7z.exe"
    set "SEVEN_ZIP_FOUND=1"
)

if !SEVEN_ZIP_FOUND! equ 0 (
    where 7z >nul 2>nul
    if !errorLevel! equ 0 (
        set "SEVEN_ZIP_PATH=7z"
        set "SEVEN_ZIP_FOUND=1"
    )
)

if !SEVEN_ZIP_FOUND! equ 0 (
    echo 7-Zip is not installed. Please install from https://www.7-zip.org/
    pause
    exit /b 1
)

:: Locate the actual .appx or .msixbundle file in the staged directory
set "APPX_FILE="
for %%f in ("%STAGING_DIR%\*.appx" "%STAGING_DIR%\*.msixbundle" "%STAGING_DIR%\*.appxbundle") do (
    if exist "%%f" (
        set "APPX_FILE=%%f"
        goto :FileFound
    )
)
:FileFound

if "!APPX_FILE!" == "" (
    echo Error: Could not find .appx or .msixbundle file in the package directory.
    dir "%STAGING_DIR%" /b
    pause
    exit /b 1
)

echo Using package file: !APPX_FILE!

:: Create extraction directory
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
mkdir "%EXTRACT_DIR%"

:: Extract APPX
echo Extracting APPX package...
"!SEVEN_ZIP_PATH!" x "!APPX_FILE!" -o"%EXTRACT_DIR%" -y
if !errorLevel! neq 0 (
    echo Failed to extract APPX.
    pause
    exit /b 1
)

:: Replace nvcpluir.dll
echo Replacing nvcpluir.dll...
if exist "%EXTRACT_DIR%\Display.Driver\NVCPL\nvcpluir.dll" (
    if exist "%NVCPLUIR_DLL%" (
        copy /y "%NVCPLUIR_DLL%" "%EXTRACT_DIR%\Display.Driver\NVCPL\nvcpluir.dll"
    ) else (
        echo Warning: %NVCPLUIR_DLL% not found in current directory. Skipping replacement.
    )
) else (
    echo Searching for nvcpluir.dll in extracted contents...
    for /f "delims=" %%i in ('dir "%EXTRACT_DIR%" /s /b ^| findstr /i "nvcpluir.dll"') do (
        echo Found at: %%i
        if exist "%NVCPLUIR_DLL%" (
            copy /y "%NVCPLUIR_DLL%" "%%i"
        )
        goto :DllFound
    )
    echo Error: nvcpluir.dll not found in expected location.
    pause
    exit /b 1
)
:DllFound

:: Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Copy necessary files
echo Copying files to "%OUTPUT_DIR%"...
copy "%EXTRACT_DIR%\Display.Driver\NVCPL\nvcplui.exe" "%OUTPUT_DIR%" >nul
copy "%EXTRACT_DIR%\Display.Driver\NVCPL\nvcpluir.dll" "%OUTPUT_DIR%" >nul
copy "%EXTRACT_DIR%\Display.Driver\NVCPL\nvcpl.dll" "%OUTPUT_DIR%" >nul

:: Verify copy
if not exist "%OUTPUT_DIR%\nvcplui.exe" (
    echo Critical Error: Failed to copy nvcplui.exe.
    pause
    exit /b 1
)

:: Create desktop shortcut
echo Creating desktop shortcut...
set "SHORTCUT_FILE=%USERPROFILE%\Desktop\NVIDIA Control Panel (Win32).lnk"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('!SHORTCUT_FILE!'); $Shortcut.TargetPath = '!OUTPUT_DIR!\nvcplui.exe'; $Shortcut.WorkingDirectory = '!OUTPUT_DIR!'; $Shortcut.Save()"

:: Add to context menu
echo Adding to desktop context menu...
reg delete "HKCR\Directory\Background\shell\NVCPLWin32" /f >nul 2>&1
reg add "HKCR\Directory\Background\shell\NVCPLWin32" /v "MUIVerb" /t REG_SZ /d "NVIDIA Control Panel (Win32)" /f
reg add "HKCR\Directory\Background\shell\NVCPLWin32" /v "Icon" /t REG_SZ /d "!OUTPUT_DIR!\nvcpl.dll,0" /f
reg add "HKCR\Directory\Background\shell\NVCPLWin32\command" /ve /t REG_SZ /d "\"!OUTPUT_DIR!\nvcplui.exe\"" /f

:: Cleanup
if exist "%STAGING_DIR%" rmdir /s /q "%STAGING_DIR%"
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"

echo Done! You can now launch NVIDIA Control Panel as a Win32 app.
ENDLOCAL
pause   