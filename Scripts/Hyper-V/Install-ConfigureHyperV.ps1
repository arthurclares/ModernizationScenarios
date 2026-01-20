#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs and configures Hyper-V on Windows Server 2022.

.DESCRIPTION
    This script performs the following tasks:
    - Checks prerequisites (hardware virtualization support)
    - Installs Hyper-V role and management tools
    - Configures default virtual machine storage paths
    - Creates a virtual switch for VM networking
    - Configures Hyper-V host settings

.NOTES
    Author: GitHub Copilot
    Date: 2026-01-20
    Requires: Windows Server 2022, Administrator privileges
    A system restart is required after installation.
#>

param(
    [string]$VMPath = "C:\Hyper-V\VMs",
    [string]$VHDPath = "C:\Hyper-V\VHDs",
    [string]$VirtualSwitchName = "External-vSwitch",
    [switch]$CreateExternalSwitch = $true,
    [switch]$SkipRestart = $false
)

# Function to write colored output
function Write-StatusMessage {
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
    
    Write-Host "$($prefix[$Type]) $Message" -ForegroundColor $colors[$Type]
}

# Function to check hardware virtualization support
function Test-VirtualizationSupport {
    Write-StatusMessage "Checking hardware virtualization support..." -Type Info
    
    $processorInfo = Get-WmiObject -Class Win32_Processor
    $vmSupport = $processorInfo.VirtualizationFirmwareEnabled
    
    if ($vmSupport -eq $true) {
        Write-StatusMessage "Hardware virtualization is enabled in BIOS/UEFI." -Type Success
        return $true
    }
    elseif ($vmSupport -eq $false) {
        Write-StatusMessage "Hardware virtualization is NOT enabled. Please enable it in BIOS/UEFI settings." -Type Error
        return $false
    }
    else {
        Write-StatusMessage "Unable to determine virtualization support. Proceeding with installation..." -Type Warning
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
    Write-StatusMessage "Installing Hyper-V role and management tools..." -Type Info
    
    try {
        # Install Hyper-V with management tools
        $installResult = Install-WindowsFeature -Name Hyper-V `
            -IncludeManagementTools `
            -IncludeAllSubFeature `
            -ErrorAction Stop
        
        if ($installResult.Success) {
            Write-StatusMessage "Hyper-V role installed successfully." -Type Success
            
            if ($installResult.RestartNeeded -eq "Yes") {
                Write-StatusMessage "A system restart is required to complete the installation." -Type Warning
                return $true
            }
        }
        else {
            Write-StatusMessage "Hyper-V installation failed." -Type Error
            return $false
        }
    }
    catch {
        Write-StatusMessage "Error installing Hyper-V: $_" -Type Error
        return $false
    }
    
    return $true
}

# Function to create storage directories
function Initialize-HyperVStorage {
    param(
        [string]$VMPath,
        [string]$VHDPath
    )
    
    Write-StatusMessage "Creating Hyper-V storage directories..." -Type Info
    
    # Create VM directory
    if (-not (Test-Path -Path $VMPath)) {
        New-Item -Path $VMPath -ItemType Directory -Force | Out-Null
        Write-StatusMessage "Created VM directory: $VMPath" -Type Success
    }
    else {
        Write-StatusMessage "VM directory already exists: $VMPath" -Type Info
    }
    
    # Create VHD directory
    if (-not (Test-Path -Path $VHDPath)) {
        New-Item -Path $VHDPath -ItemType Directory -Force | Out-Null
        Write-StatusMessage "Created VHD directory: $VHDPath" -Type Success
    }
    else {
        Write-StatusMessage "VHD directory already exists: $VHDPath" -Type Info
    }
}

# Function to configure Hyper-V host settings
function Set-HyperVHostConfiguration {
    param(
        [string]$VMPath,
        [string]$VHDPath
    )
    
    Write-StatusMessage "Configuring Hyper-V host settings..." -Type Info
    
    try {
        # Set default paths for VMs and VHDs
        Set-VMHost -VirtualMachinePath $VMPath `
                   -VirtualHardDiskPath $VHDPath `
                   -ErrorAction Stop
        
        # Enable enhanced session mode
        Set-VMHost -EnableEnhancedSessionMode $true -ErrorAction Stop
        
        # Configure NUMA spanning (useful for large VMs)
        Set-VMHost -NumaSpanningEnabled $true -ErrorAction Stop
        
        Write-StatusMessage "Hyper-V host configuration completed." -Type Success
        
        # Display current configuration
        $vmHost = Get-VMHost
        Write-StatusMessage "Current Hyper-V Host Configuration:" -Type Info
        Write-Host "  Virtual Machine Path: $($vmHost.VirtualMachinePath)"
        Write-Host "  Virtual Hard Disk Path: $($vmHost.VirtualHardDiskPath)"
        Write-Host "  Enhanced Session Mode: $($vmHost.EnableEnhancedSessionMode)"
        Write-Host "  NUMA Spanning: $($vmHost.NumaSpanningEnabled)"
    }
    catch {
        Write-StatusMessage "Error configuring Hyper-V host: $_" -Type Error
    }
}

# Function to create virtual switch
function New-HyperVVirtualSwitch {
    param(
        [string]$SwitchName
    )
    
    Write-StatusMessage "Creating virtual switch..." -Type Info
    
    # Check if switch already exists
    $existingSwitch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
    if ($existingSwitch) {
        Write-StatusMessage "Virtual switch '$SwitchName' already exists." -Type Info
        return
    }
    
    try {
        # Get available physical network adapters
        $netAdapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" }
        
        if ($netAdapters.Count -eq 0) {
            Write-StatusMessage "No active physical network adapters found. Creating internal switch instead." -Type Warning
            
            # Create internal switch
            New-VMSwitch -Name "$SwitchName-Internal" `
                        -SwitchType Internal `
                        -ErrorAction Stop
            
            Write-StatusMessage "Created internal virtual switch: $SwitchName-Internal" -Type Success
        }
        else {
            # Display available adapters
            Write-StatusMessage "Available network adapters:" -Type Info
            $netAdapters | ForEach-Object { Write-Host "  - $($_.Name): $($_.InterfaceDescription)" }
            
            # Use the first available adapter for external switch
            $primaryAdapter = $netAdapters | Select-Object -First 1
            
            New-VMSwitch -Name $SwitchName `
                        -NetAdapterName $primaryAdapter.Name `
                        -AllowManagementOS $true `
                        -ErrorAction Stop
            
            Write-StatusMessage "Created external virtual switch: $SwitchName (bound to $($primaryAdapter.Name))" -Type Success
        }
    }
    catch {
        Write-StatusMessage "Error creating virtual switch: $_" -Type Error
    }
}

# Function to configure firewall rules for Hyper-V
function Set-HyperVFirewallRules {
    Write-StatusMessage "Configuring firewall rules for Hyper-V..." -Type Info
    
    try {
        # Enable Hyper-V firewall rules
        $hyperVRules = Get-NetFirewallRule -DisplayGroup "Hyper-V*" -ErrorAction SilentlyContinue
        
        if ($hyperVRules) {
            $hyperVRules | Enable-NetFirewallRule -ErrorAction SilentlyContinue
            Write-StatusMessage "Hyper-V firewall rules enabled." -Type Success
        }
        
        # Enable VM monitoring rules
        $vmMonitorRules = Get-NetFirewallRule -DisplayGroup "Virtual Machine Monitoring" -ErrorAction SilentlyContinue
        if ($vmMonitorRules) {
            $vmMonitorRules | Enable-NetFirewallRule -ErrorAction SilentlyContinue
            Write-StatusMessage "Virtual Machine Monitoring firewall rules enabled." -Type Success
        }
    }
    catch {
        Write-StatusMessage "Error configuring firewall rules: $_" -Type Error
    }
}

# Main execution
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Hyper-V Installation and Configuration Script" -ForegroundColor Cyan
Write-Host "  Windows Server 2022" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-StatusMessage "This script must be run as Administrator. Please restart PowerShell with elevated privileges." -Type Error
    exit 1
}

# Check virtualization support
if (-not (Test-VirtualizationSupport)) {
    Write-StatusMessage "Cannot proceed without hardware virtualization support." -Type Error
    exit 1
}

# Check if Hyper-V is already installed
if (Test-HyperVInstalled) {
    Write-StatusMessage "Hyper-V is already installed. Proceeding with configuration..." -Type Info
}
else {
    # Install Hyper-V
    $installSuccess = Install-HyperVRole
    
    if (-not $installSuccess) {
        Write-StatusMessage "Hyper-V installation failed. Exiting..." -Type Error
        exit 1
    }
    
    # Check if restart is needed
    $feature = Get-WindowsFeature -Name Hyper-V
    if ($feature.InstallState -eq "InstallPending") {
        Write-StatusMessage "Hyper-V installation is pending a restart." -Type Warning
        Write-StatusMessage "Please restart the server and run this script again to complete configuration." -Type Warning
        
        if (-not $SkipRestart) {
            $response = Read-Host "Would you like to restart now? (Y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                Write-StatusMessage "Restarting server in 10 seconds..." -Type Warning
                Start-Sleep -Seconds 10
                Restart-Computer -Force
            }
        }
        exit 0
    }
}

# Configure Hyper-V (only runs if Hyper-V is fully installed)
try {
    # Import Hyper-V module
    Import-Module Hyper-V -ErrorAction Stop
    
    # Create storage directories
    Initialize-HyperVStorage -VMPath $VMPath -VHDPath $VHDPath
    
    # Configure host settings
    Set-HyperVHostConfiguration -VMPath $VMPath -VHDPath $VHDPath
    
    # Create virtual switch
    if ($CreateExternalSwitch) {
        New-HyperVVirtualSwitch -SwitchName $VirtualSwitchName
    }
    
    # Configure firewall rules
    Set-HyperVFirewallRules
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-StatusMessage "Hyper-V installation and configuration completed successfully!" -Type Success
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-StatusMessage "Next steps:" -Type Info
    Write-Host "  1. Use Hyper-V Manager or PowerShell to create virtual machines"
    Write-Host "  2. Configure additional virtual switches as needed"
    Write-Host "  3. Set up VM replication if required"
    Write-Host ""
}
catch {
    Write-StatusMessage "Error during configuration: $_" -Type Error
    Write-StatusMessage "The Hyper-V module may not be available. Try restarting the server first." -Type Warning
}
