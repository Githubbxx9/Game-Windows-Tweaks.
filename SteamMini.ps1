# Set Steam Flags (Shortcut and Registry)

# 1. Update Desktop Shortcut
$steamPath = "C:\Program Files (x86)\Steam\Steam.exe"
$shortcutPath = "$env:USERPROFILE\Desktop\Steam.lnk"

# Comprehensive list of all flags from the registry template
$steamFlags = @(
    "-silent",
    "-dev",
    "-nofriendsui",
    "-no-dwrite",
    "-nointro",
    "-nobigpicture",
    "-nofasthtml",
    "-nocrashmonitor",
    "-noshaders",
    "-no-shared-textures",
    "-disablehighdpi",
    "-cef-single-process",
    "-cef-in-process-gpu",
    "-single_core",
    "-cef-disable-d3d11",
    "-cef-disable-sandbox",
    "-disable-winh264",
    "-no-cef-sandbox",
    "-vrdisable",
    "-cef-disable-breakpad",
    "-cef-disable-gpu-compositing",
    "-cef-disable-gpu",
    "-cef-disable-js-logging",
    "-cef-disable-occlusion",
    "-cef-disable-renderer-restart",
    "-noconsole",
    "-oldtraymenu",
    "-showallbetas",
    "+open steam://open/minigameslist"
)

# Convert array to a single string for arguments
$argValue = $steamFlags -join " "

# Create/update the desktop shortcut
$wsh = New-Object -ComObject WScript.Shell
$sc = $wsh.CreateShortcut($shortcutPath)
$sc.TargetPath = $steamPath
$sc.Arguments = $argValue
$sc.WorkingDirectory = Split-Path $steamPath
$sc.IconLocation = "$steamPath, 0"
$sc.Save()

Write-Host "Desktop shortcut created or updated at: $shortcutPath"

# 2. Update Windows Registry Run on Startup
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$registryValueName = "Steam"

# Combine the executable path and full arguments string for the registry
# Executable path is wrapped in quotes to handle spaces correctly
$registryValueData = "`"$steamPath`" $argValue"

# Set the registry key value
Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $registryValueData
Write-Host "Registry startup item updated at: $registryPath"

Write-Host "--------------------------------------------------------"
Write-Host "If Steam is pinned to the taskbar, unpin the old one, launch the new shortcut, then pin it again."
Write-Host "Ensure you close all running steam.exe processes before testing."
