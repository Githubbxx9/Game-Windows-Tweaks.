#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Removes unused Network Adapter drivers while preserving the active Ethernet connection.
.DESCRIPTION
    This script identifies the currently active physical Ethernet adapter, protects its driver,
    and removes all other network driver packages from the driver store using pnputil.
.NOTES
    Author: Automated Assistant
    Date: June 2026
#>

# --- Configuration ---
$ErrorActionPreference = "Continue"
$PauseAtEnd = $true # Set to $false if running via Task Scheduler

# --- Helper: Keep Window Open ---
function Stop-Script {
    param([string]$Message)
    if ($Message) { Write-Host $Message }
    if ($PauseAtEnd) {
        Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
        Read-Host | Out-Null
    }
    exit
}

# --- Header ---
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Network Adapter Driver Cleanup Utility" -ForegroundColor White
Write-Host "   Started: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "WARNING: This will remove driver packages from the system." -ForegroundColor Red
Write-Host "Target: All Network Adapters EXCEPT the active Ethernet." -ForegroundColor White
Write-Host "Ensure you have internet access or drivers saved locally." -ForegroundColor Yellow
Write-Host ""

# --- Step 1: Identify Active Ethernet Driver ---
Write-Host "[1/3] Identifying active Ethernet adapter..." -ForegroundColor Cyan
try {
    # Get active physical Ethernet (Exclude Wi-Fi, Virtual, Bluetooth, etc.)
    $EthernetAdapter = Get-NetAdapter | Where-Object { 
        $_.Status -eq 'Up' -and 
        $_.InterfaceDescription -notmatch 'Wireless|Wi-Fi|Bluetooth|Virtual|TAP|TUN|Loopback|Kernel|Panda' 
    } | Select-Object -First 1

    if (-not $EthernetAdapter) {
        throw "No active physical Ethernet adapter found. Aborting to prevent network loss."
    }

    Write-Host "  Found: $($EthernetAdapter.InterfaceDescription)" -ForegroundColor Green
    Write-Host "  MAC: $($EthernetAdapter.MacAddress)" -ForegroundColor Gray

    # Map to PnP Device to find the specific Driver INF
    $PnPDevice = Get-PnpDevice | Where-Object { 
        $_.Class -eq 'Net' -and 
        $_.Status -eq 'OK' -and 
        ($_.FriendlyName -eq $EthernetAdapter.InterfaceDescription -or $_.InstanceId -like "*$($EthernetAdapter.MacAddress)*") 
    } | Select-Object -First 1

    # Fallback match if MAC address logic fails
    if (-not $PnPDevice) {
        $PnPDevice = Get-PnpDevice -Class Net | Where-Object { $_.FriendlyName -eq $EthernetAdapter.InterfaceDescription } | Select-Object -First 1
    }

    if (-not $PnPDevice) { throw "Could not map network adapter to a PnP Device." }

    # Get the Published INF Name (e.g., oem12.inf)
    $InfProperty = Get-PnpDeviceProperty -InstanceId $PnPDevice.InstanceId -KeyName 'DEVPKEY_Device_DriverInfPath' -ErrorAction SilentlyContinue
    $ProtectedInf = $InfProperty.Data

    if (-not $ProtectedInf) { throw "Could not determine the INF filename for the active driver." }
    
    Write-Host "  Protected Driver: $ProtectedInf" -ForegroundColor Green
}
catch {
    Write-Host "  CRITICAL ERROR: $_" -ForegroundColor Red
    Stop-Script
}

# --- Step 2: Enumerate Targets ---
Write-Host "`n[2/3] Scanning for removable drivers..." -ForegroundColor Cyan

$Targets = Get-PnpDevice -Class Net | Where-Object { 
    $_.InstanceId -ne $PnPDevice.InstanceId -and 
    $_.InstanceId -notlike "*$($ProtectedInf)*" -and 
    $_.FriendlyName -ne $EthernetAdapter.InterfaceDescription 
    # Add '-and $_.Status -eq "Unknown"' here if you ONLY want to remove ghost devices
}

if ($Targets.Count -eq 0) {
    Write-Host "  No other network adapter drivers found to remove." -ForegroundColor Yellow
    Stop-Script
}

Write-Host "  Found $($Targets.Count) driver(s) marked for removal." -ForegroundColor Yellow

# --- Confirmation ---
Write-Host "`nDo you want to proceed with removal? (Y/N)" -ForegroundColor Yellow
$confirmation = Read-Host
if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "Operation cancelled by user." -ForegroundColor Gray
    Stop-Script
}

# --- Step 3: Removal Process ---
Write-Host "`n[3/3] Starting removal process..." -ForegroundColor Cyan
$RemovedCount = 0
$FailedCount = 0

foreach ($Device in $Targets) {
    $InfProp = Get-PnpDeviceProperty -InstanceId $Device.InstanceId -KeyName 'DEVPKEY_Device_DriverInfPath' -ErrorAction SilentlyContinue
    $DriverInf = $InfProp.Data

    if (-not $DriverInf) {
        Write-Host "  Skipping $($Device.FriendlyName): Could not retrieve INF." -ForegroundColor Gray
        continue
    }

    # Avoid deleting the same INF twice if multiple devices share it
    if ($DriverInf -eq $ProtectedInf) { continue }

    Write-Host "  Removing: $($Device.FriendlyName) ($DriverInf)..." -ForegroundColor Cyan
    
    try {
        # Use pnputil to delete the driver package
        # /force: Removes driver even if it is currently installed on a disconnected device
        $Result = pnputil /delete-driver $DriverInf /uninstall /force 2>&1
        
        if ($LASTEXITCODE -eq 0 -or $Result -like "*deleted successfully*" -or $Result -like "*No matching driver packages found*") {
            Write-Host "    -> Success." -ForegroundColor Green
            $RemovedCount++
        } else {
            Write-Host "    -> Warning: pnputil returned code $LASTEXITCODE. Driver may be in use." -ForegroundColor Yellow
            $FailedCount++
        }
    }
    catch {
        Write-Host "    -> Failed: $_" -ForegroundColor Red
        $FailedCount++
    }
}

# --- Summary ---
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "   Cleanup Complete" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Drivers Removed: $RemovedCount" -ForegroundColor Green
Write-Host "Drivers Skipped/Failed: $FailedCount" -ForegroundColor Yellow
Write-Host "Active Driver Preserved: $ProtectedInf" -ForegroundColor Green

Stop-Script   