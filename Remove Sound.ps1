# Requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    WriteWarning "Please run this script as an Administrator!"
    Break
}

# 1. Define Patterns
$includePatterns = @("*Audio*", "*Sound*", "*Microphone*", "*Headset*", "*Speaker*", "*Realtek*", "*Conexant*", "*IDT*", "*NVIDIA High Definition Audio*", "*Voice Clarity*", "*VoiceClarity*", "*Dolby*", "*Nahimic*", "*Sonic Studio*")
$excludePatterns = @("*Ethernet*", "*Network*", "*Controller*", "*GbE*", "*Wi-Fi*", "*Wireless*", "*Bluetooth*")

Write-Host "Scanning for devices..." -ForegroundColor Cyan

# 2. Retrieve and Filter Devices
# We get all devices, then filter by FriendlyName using the patterns
$allDevices = Get-PnpDevice -Status 'OK' | Where-Object { $_.FriendlyName }

$targetDevices = $allDevices | Where-Object {
    $name = $_.FriendlyName
    $isIncluded = $false
    $isExcluded = $false

    # Check Include patterns
    foreach ($pattern in $includePatterns) {
        if ($name -like $pattern) {
            $isIncluded = $true
            break
        }
    }

    # Check Exclude patterns (takes precedence)
    if ($isIncluded) {
        foreach ($pattern in $excludePatterns) {
            if ($name -like $pattern) {
                $isExcluded = $true
                break
            }
        }
    }

    return ($isIncluded -and -not $isExcluded)
}

if ($targetDevices.Count -eq 0) {
    Write-Host "No matching devices found based on your patterns." -ForegroundColor Yellow
    Exit
}

Write-Host "Found $($targetDevices.Count) matching device(s):" -ForegroundColor Green
$targetDevices | ForEach-Object { Write-Host " - $($_.FriendlyName) ($($_.InstanceId))" }

# 3. Action: Disable Devices (Recommended for "Removal")
# Disabling stops the device from functioning without deleting the driver files, 
# which is safer and reversible.
Write-Host "`n[Step 1] Disabling devices..." -ForegroundColor Yellow
foreach ($dev in $targetDevices) {
    try {
        # -Confirm:$false suppresses the interactive prompt
        Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
        Write-Host "Disabled: $($dev.FriendlyName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to disable $($dev.FriendlyName): $_" -ForegroundColor Red
    }
}

# 4. Action: Uninstall Devices (Optional - For Permanent Driver Removal)
# UNCOMMENT the block below if you want to completely uninstall the driver package.
# WARNING: Windows may attempt to reinstall these drivers automatically on reboot.
<#
Write-Host "`n[Step 2] Uninstalling device drivers (Permanent Removal)..." -ForegroundColor Yellow
foreach ($dev in $targetDevices) {
    try {
        # pnputil is often more reliable for full driver removal than Remove-PnpDevice
        pnputil /remove-device $dev.InstanceId
        Write-Host "Uninstalled: $($dev.FriendlyName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to uninstall $($dev.FriendlyName): $_" -ForegroundColor Red
    }
}
#>

Write-Host "`nOperation completed." -ForegroundColor Cyan 

Pause  