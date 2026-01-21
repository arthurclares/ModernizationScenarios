#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Zero-touch installation and configuration of Hyper-V infrastructure.

.DESCRIPTION
    This script performs the following tasks with NO user interaction required:
    - Checks prerequisites (hardware virtualization support)
    - Installs Hyper-V role and management tools
    - Creates storage directories for VMs, VHDs, and ISOs
    - Configures Hyper-V host settings (paths, enhanced session mode, NUMA spanning)
    - Creates multiple virtual switches for VM networking:
      * External switch (bound to physical adapter if available)
      * Internal switch (ALWAYS created as fallback)
      * Private switch (for isolated testing)
    - Configures firewall rules for Hyper-V

    For Ubuntu VM deployment, use the separate Deploy-UbuntuVM.ps1 script.

.PARAMETER VMPath
    Path where virtual machine configuration files will be stored. Default: "C:\Hyper-V\VMs"

.PARAMETER VHDPath
    Path where virtual hard disk files will be stored. Default: "C:\Hyper-V\VHDs"

.PARAMETER ISOPath
    Path where ISO files will be stored. Default: "C:\Hyper-V\ISOs"

.PARAMETER ExternalSwitchName
    Name for the external virtual switch. Default: "External-vSwitch"

.PARAMETER InternalSwitchName
    Name for the internal virtual switch. Default: "Internal-vSwitch"

.PARAMETER AutoRestart
    Automatically restart if Hyper-V installation requires it. Default: $false

.EXAMPLE
    .\Install-ConfigureHyperV.ps1
    
    Installs and configures Hyper-V with default settings.

.EXAMPLE
    .\Install-ConfigureHyperV.ps1 -AutoRestart
    
    Installs Hyper-V and automatically restarts if needed.

.EXAMPLE
    .\Install-ConfigureHyperV.ps1 -VMPath "D:\VMs" -VHDPath "D:\VHDs"
    
    Installs Hyper-V with custom storage paths.

.NOTES
    Author: Arthur Clares
    Date: 2026-01-21
    Requires: Windows Server 2022, Administrator privileges
    Zero-Touch: No user prompts - fully automated operation
#>

param(
    [string]$VMPath = "C:\Hyper-V\VMs",
    [string]$VHDPath = "C:\Hyper-V\VHDs",
    [string]$ISOPath = "C:\Hyper-V\ISOs",
    [string]$ExternalSwitchName = "External-vSwitch",
    [string]$InternalSwitchName = "Internal-vSwitch",
    [switch]$AutoRestart = $false
)

# Function to write timestamped log messages
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )
    
    $colors = @{
        "Info"    = "Cyan"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error"   = "Red"
    }
    
    $prefix = @{
        "Info"    = "[INFO]"
        "Success" = "[SUCCESS]"
        "Warning" = "[WARNING]"
        "Error"   = "[ERROR]"
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $($prefix[$Type]) $Message" -ForegroundColor $colors[$Type]
}

# Function to check hardware virtualization support
function Test-VirtualizationSupport {
    Write-Log "Checking hardware virtualization support..." -Type Info
    
    $processorInfo = Get-CimInstance -ClassName Win32_Processor
    $vmSupport = $processorInfo.VirtualizationFirmwareEnabled
    
    if ($vmSupport -eq $true) {
        Write-Log "Hardware virtualization is enabled in BIOS/UEFI." -Type Success
        return $true
    }
    elseif ($vmSupport -eq $false) {
        Write-Log "Hardware virtualization is NOT enabled. Please enable it in BIOS/UEFI settings." -Type Error
        return $false
    }
    else {
        Write-Log "Unable to determine virtualization support. Proceeding with installation..." -Type Warning
        return $true
    }
}

# Function to check if Hyper-V is already installed
function Test-HyperVInstalled {
    $hyperVFeature = Get-WindowsFeature -Name Hyper-V
    return $hyperVFeature.Installed
}

# Function to install Hyper-V
function Install-HyperVRole {
    Write-Log "Installing Hyper-V role and management tools..." -Type Info
    
    try {
        # Install Hyper-V with management tools
        $installResult = Install-WindowsFeature -Name Hyper-V `
            -IncludeManagementTools `
            -IncludeAllSubFeature `
            -ErrorAction Stop
        
        if ($installResult.Success) {
            Write-Log "Hyper-V role installed successfully." -Type Success
            
            if ($installResult.RestartNeeded -eq "Yes") {
                Write-Log "A system restart is required to complete the installation." -Type Warning
                return $true
            }
        }
        else {
            Write-Log "Hyper-V installation failed." -Type Error
            return $false
        }
    }
    catch {
        Write-Log "Error installing Hyper-V: $_" -Type Error
        return $false
    }
    
    return $true
}

# Function to create storage directories
function Initialize-HyperVStorage {
    param(
        [string]$VMPath,
        [string]$VHDPath,
        [string]$ISOPath
    )
    
    Write-Log "Creating Hyper-V storage directories..." -Type Info
    
    # Create VM directory
    if (-not (Test-Path -Path $VMPath)) {
        New-Item -Path $VMPath -ItemType Directory -Force | Out-Null
        Write-Log "Created VM directory: $VMPath" -Type Success
    }
    else {
        Write-Log "VM directory already exists: $VMPath" -Type Info
    }
    
    # Create VHD directory
    if (-not (Test-Path -Path $VHDPath)) {
        New-Item -Path $VHDPath -ItemType Directory -Force | Out-Null
        Write-Log "Created VHD directory: $VHDPath" -Type Success
    }
    else {
        Write-Log "VHD directory already exists: $VHDPath" -Type Info
    }
    
    # Create ISO directory
    if (-not (Test-Path -Path $ISOPath)) {
        New-Item -Path $ISOPath -ItemType Directory -Force | Out-Null
        Write-Log "Created ISO directory: $ISOPath" -Type Success
    }
    else {
        Write-Log "ISO directory already exists: $ISOPath" -Type Info
    }
}

# Function to configure Hyper-V host settings
function Set-HyperVHostConfiguration {
    param(
        [string]$VMPath,
        [string]$VHDPath
    )
    
    Write-Log "Configuring Hyper-V host settings..." -Type Info
    
    try {
        # Set default paths for VMs and VHDs
        Set-VMHost -VirtualMachinePath $VMPath `
                   -VirtualHardDiskPath $VHDPath `
                   -ErrorAction Stop
        
        # Enable enhanced session mode
        Set-VMHost -EnableEnhancedSessionMode $true -ErrorAction Stop
        
        # Configure NUMA spanning (useful for large VMs)
        Set-VMHost -NumaSpanningEnabled $true -ErrorAction Stop
        
        Write-Log "Hyper-V host configuration completed." -Type Success
        
        # Display current configuration
        $vmHost = Get-VMHost
        Write-Log "Current Hyper-V Host Configuration:" -Type Info
        Write-Host "  Virtual Machine Path: $($vmHost.VirtualMachinePath)"
        Write-Host "  Virtual Hard Disk Path: $($vmHost.VirtualHardDiskPath)"
        Write-Host "  Enhanced Session Mode: $($vmHost.EnableEnhancedSessionMode)"
        Write-Host "  NUMA Spanning: $($vmHost.NumaSpanningEnabled)"
    }
    catch {
        Write-Log "Error configuring Hyper-V host: $_" -Type Error
    }
}

# Function to create virtual switches
function New-HyperVVirtualSwitches {
    param(
        [string]$ExternalSwitchName,
        [string]$InternalSwitchName
    )
    
    Write-Log "Creating virtual switches for VM networking..." -Type Info
    Write-Host ""
    
    # External Switch - try to create, but don't fail if no adapter
    Write-Log "Creating external virtual switch..." -Type Info
    try {
        # Check if external switch already exists
        $existingExternal = Get-VMSwitch -Name $ExternalSwitchName -ErrorAction SilentlyContinue
        if ($existingExternal) {
            Write-Log "External virtual switch '$ExternalSwitchName' already exists." -Type Info
        }
        else {
            # Get available physical network adapters
            $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" }
            
            if ($adapters.Count -gt 0) {
                $adapter = $adapters | Select-Object -First 1
                Write-Log "Found active network adapter: $($adapter.Name) - $($adapter.InterfaceDescription)" -Type Info
                
                New-VMSwitch -Name $ExternalSwitchName `
                             -NetAdapterName $adapter.Name `
                             -AllowManagementOS $true `
                             -ErrorAction Stop | Out-Null
                
                Write-Log "Created external virtual switch: $ExternalSwitchName (bound to $($adapter.Name))" -Type Success
            }
            else {
                Write-Log "No active physical network adapters found. Skipping external switch creation." -Type Warning
            }
        }
    }
    catch {
        Write-Log "Error creating external virtual switch: $_" -Type Warning
        Write-Log "Continuing with other virtual switches..." -Type Info
    }
    
    Write-Host ""
    
    # Internal Switch - ALWAYS create as fallback
    Write-Log "Creating internal virtual switch (always created as fallback)..." -Type Info
    try {
        # Check if internal switch already exists
        $existingInternal = Get-VMSwitch -Name $InternalSwitchName -ErrorAction SilentlyContinue
        if ($existingInternal) {
            Write-Log "Internal virtual switch '$InternalSwitchName' already exists." -Type Info
        }
        else {
            New-VMSwitch -Name $InternalSwitchName `
                         -SwitchType Internal `
                         -ErrorAction Stop | Out-Null
            
            Write-Log "Created internal virtual switch: $InternalSwitchName" -Type Success
        }
    }
    catch {
        Write-Log "Error creating internal virtual switch: $_" -Type Error
    }
    
    Write-Host ""
    
    # Private Switch - create for isolated testing
    Write-Log "Creating private virtual switch for isolated testing..." -Type Info
    try {
        $privateSwitchName = "Private-vSwitch"
        
        # Check if private switch already exists
        $existingPrivate = Get-VMSwitch -Name $privateSwitchName -ErrorAction SilentlyContinue
        if ($existingPrivate) {
            Write-Log "Private virtual switch '$privateSwitchName' already exists." -Type Info
        }
        else {
            New-VMSwitch -Name $privateSwitchName `
                         -SwitchType Private `
                         -ErrorAction Stop | Out-Null
            
            Write-Log "Created private virtual switch: $privateSwitchName" -Type Success
        }
    }
    catch {
        Write-Log "Error creating private virtual switch: $_" -Type Warning
        Write-Log "This is optional and does not affect VM deployment." -Type Info
    }
    
    Write-Host ""
}

# Function to configure firewall rules for Hyper-V
function Set-HyperVFirewallRules {
    Write-Log "Configuring firewall rules for Hyper-V..." -Type Info
    
    try {
        # Enable Hyper-V firewall rules
        $hyperVRules = Get-NetFirewallRule -DisplayGroup "Hyper-V*" -ErrorAction SilentlyContinue
        
        if ($hyperVRules) {
            $hyperVRules | Enable-NetFirewallRule -ErrorAction SilentlyContinue
            Write-Log "Hyper-V firewall rules enabled." -Type Success
        }
        
        # Enable VM monitoring rules
        $vmMonitorRules = Get-NetFirewallRule -DisplayGroup "Virtual Machine Monitoring" -ErrorAction SilentlyContinue
        if ($vmMonitorRules) {
            $vmMonitorRules | Enable-NetFirewallRule -ErrorAction SilentlyContinue
            Write-Log "Virtual Machine Monitoring firewall rules enabled." -Type Success
        }
    }
    catch {
        Write-Log "Error configuring firewall rules: $_" -Type Error
    }
}

# Main execution
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Zero-Touch Hyper-V Infrastructure Setup" -ForegroundColor Cyan
Write-Host "  Windows Server 2022" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "This script must be run as Administrator. Please restart PowerShell with elevated privileges." -Type Error
    exit 1
}

# Check virtualization support
if (-not (Test-VirtualizationSupport)) {
    Write-Log "Cannot proceed without hardware virtualization support." -Type Error
    exit 1
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "  STEP 1: Hyper-V Installation" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

# Check if Hyper-V is already installed
if (Test-HyperVInstalled) {
    Write-Log "Hyper-V is already installed. Proceeding with configuration..." -Type Info
}
else {
    # Install Hyper-V
    $installSuccess = Install-HyperVRole
    
    if (-not $installSuccess) {
        Write-Log "Hyper-V installation failed. Exiting..." -Type Error
        exit 1
    }
    
    # Check if restart is needed
    $feature = Get-WindowsFeature -Name Hyper-V
    if ($feature.InstallState -eq "InstallPending") {
        Write-Log "Hyper-V installation is pending a restart." -Type Warning
        
        if ($AutoRestart) {
            Write-Log "Auto-restart enabled. Restarting server in 30 seconds..." -Type Warning
            Write-Log "After restart, please run this script again to complete configuration." -Type Info
            Start-Sleep -Seconds 30
            Restart-Computer -Force
        }
        else {
            Write-Log "Please restart the server and run this script again to complete configuration." -Type Warning
            Write-Log "To enable automatic restart, use the -AutoRestart parameter." -Type Info
        }
        exit 0
    }
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "  STEP 2: Hyper-V Configuration" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

# Configure Hyper-V (only runs if Hyper-V is fully installed)
try {
    # Import Hyper-V module
    Import-Module Hyper-V -ErrorAction Stop
    
    # Create storage directories
    Initialize-HyperVStorage -VMPath $VMPath -VHDPath $VHDPath -ISOPath $ISOPath
    
    # Configure host settings
    Set-HyperVHostConfiguration -VMPath $VMPath -VHDPath $VHDPath
    
    Write-Log "Hyper-V configuration completed successfully." -Type Success
}
catch {
    Write-Log "Error during configuration: $_" -Type Error
    Write-Log "The Hyper-V module may not be available. Try restarting the server first." -Type Warning
    exit 1
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "  STEP 3: Virtual Switch Creation" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

# Create virtual switches
New-HyperVVirtualSwitches -ExternalSwitchName $ExternalSwitchName -InternalSwitchName $InternalSwitchName

Write-Host ""
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "  STEP 4: Firewall Configuration" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

# Configure firewall rules
Set-HyperVFirewallRules

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "  Hyper-V Infrastructure Setup Completed!" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Display summary
Write-Log "Deployment Summary:" -Type Info
Write-Host "  ✓ Hyper-V: Installed and configured"
Write-Host "  ✓ Storage Paths:"
Write-Host "    - VMs: $VMPath"
Write-Host "    - VHDs: $VHDPath"
Write-Host "    - ISOs: $ISOPath"

Write-Host ""
Write-Log "Available Virtual Switches:" -Type Info
$switches = Get-VMSwitch
if ($switches) {
    foreach ($switch in $switches) {
        $switchType = $switch.SwitchType
        $notes = ""
        if ($switch.NetAdapterInterfaceDescription) {
            $notes = " (bound to: $($switch.NetAdapterInterfaceDescription))"
        }
        Write-Host "  ✓ $($switch.Name) - $switchType$notes"
    }
}
else {
    Write-Host "  ! No virtual switches found. Please create switches manually."
}

Write-Host ""
Write-Log "Next Steps:" -Type Info
Write-Host "  1. Deploy Ubuntu VMs using the separate script:"
Write-Host "     .\Deploy-UbuntuVM.ps1"
Write-Host ""
Write-Host "  2. Or create custom VMs using Hyper-V Manager or PowerShell:"
Write-Host "     New-VM -Name 'MyVM' -MemoryStartupBytes 4GB"
Write-Host ""
Write-Host "  3. Configure additional virtual switches if needed:"
Write-Host "     New-VMSwitch -Name 'MySwitch' -SwitchType Internal"

Write-Host ""
