#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Zero-touch installation and configuration of Hyper-V with automated Ubuntu VM deployment.

.DESCRIPTION
    This script performs the following tasks with NO user interaction required:
    - Checks prerequisites (hardware virtualization support)
    - Installs Hyper-V role and management tools
    - Configures default virtual machine storage paths
    - Creates a virtual switch for VM networking
    - Configures Hyper-V host settings
    - Downloads Ubuntu Server ISO automatically
    - Creates and starts Ubuntu VM

.NOTES
    Author: GitHub Copilot
    Date: 2026-01-20
    Requires: Windows Server 2022, Administrator privileges
    Zero-Touch: No user prompts - fully automated operation
#>

param(
    [string]$VMPath = "C:\Hyper-V\VMs",
    [string]$VHDPath = "C:\Hyper-V\VHDs",
    [string]$ISOPath = "C:\Hyper-V\ISOs",
    [string]$VirtualSwitchName = "External-vSwitch",
    [switch]$CreateExternalSwitch = $true,
    [switch]$AutoRestart = $false,
    [switch]$DeployUbuntuVM = $true,
    [switch]$AutoStartVM = $true,
    [string]$UbuntuVMName = "Ubuntu-Server",
    [long]$UbuntuVMMemory = 4GB,
    [long]$UbuntuVMDiskSize = 50GB,
    [int]$UbuntuVMCPUCount = 2,
    [string]$UbuntuISOUrl = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
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
        [string]$VHDPath,
        [string]$ISOPath
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
    
    # Create ISO directory
    if (-not (Test-Path -Path $ISOPath)) {
        New-Item -Path $ISOPath -ItemType Directory -Force | Out-Null
        Write-StatusMessage "Created ISO directory: $ISOPath" -Type Success
    }
    else {
        Write-StatusMessage "ISO directory already exists: $ISOPath" -Type Info
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

# Function to download Ubuntu ISO
function Get-UbuntuISO {
    param(
        [string]$ISOPath,
        [string]$ISOUrl
    )
    
    $fileName = [System.IO.Path]::GetFileName($ISOUrl)
    $fullPath = Join-Path -Path $ISOPath -ChildPath $fileName
    
    if (Test-Path $fullPath) {
        Write-StatusMessage "Ubuntu ISO already exists: $fullPath" -Type Success
        return $fullPath
    }
    
    Write-StatusMessage "Downloading Ubuntu ISO (~2.5GB)..." -Type Info
    Write-StatusMessage "URL: $ISOUrl" -Type Info
    Write-StatusMessage "Destination: $fullPath" -Type Info
    
    try {
        # Try BITS transfer first (supports resume and progress)
        Import-Module BitsTransfer -ErrorAction Stop
        Start-BitsTransfer -Source $ISOUrl -Destination $fullPath -DisplayName "Ubuntu ISO Download" -Description "Downloading Ubuntu Server ISO"
        Write-StatusMessage "Ubuntu ISO downloaded successfully." -Type Success
        return $fullPath
    }
    catch {
        Write-StatusMessage "BITS transfer failed, using WebClient..." -Type Warning
        
        try {
            $webClient = New-Object System.Net.WebClient
            $downloadComplete = $false
            $downloadError = $null
            
            # Add progress event handler
            Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
                $percent = $Event.SourceEventArgs.ProgressPercentage
                Write-Progress -Activity "Downloading Ubuntu ISO" -Status "$percent% Complete" -PercentComplete $percent
            } | Out-Null
            
            # Add completion event handler
            Register-ObjectEvent -InputObject $webClient -EventName DownloadFileCompleted -Action {
                $script:downloadComplete = $true
                if ($Event.SourceEventArgs.Error) {
                    $script:downloadError = $Event.SourceEventArgs.Error
                }
            } | Out-Null
            
            # Download the file
            $webClient.DownloadFileAsync($ISOUrl, $fullPath)
            
            # Wait for download to complete
            while ($webClient.IsBusy) {
                Start-Sleep -Milliseconds 100
            }
            
            # Clean up event registrations
            Get-EventSubscriber | Where-Object { $_.SourceObject -eq $webClient } | Unregister-Event
            
            Write-Progress -Activity "Downloading Ubuntu ISO" -Completed
            $webClient.Dispose()
            
            # Check for errors
            if ($downloadError) {
                Write-StatusMessage "Download failed: $downloadError" -Type Error
                return $null
            }
            
            if (-not (Test-Path $fullPath)) {
                Write-StatusMessage "Download completed but file not found." -Type Error
                return $null
            }
            
            Write-StatusMessage "Ubuntu ISO downloaded successfully." -Type Success
            return $fullPath
        }
        catch {
            Write-StatusMessage "Failed to download Ubuntu ISO: $_" -Type Error
            return $null
        }
    }
}

# Function to create Ubuntu VM
function New-UbuntuVM {
    param(
        [string]$VMName,
        [string]$VMPath,
        [string]$VHDPath,
        [long]$MemorySize,
        [long]$DiskSize,
        [int]$ProcessorCount,
        [string]$SwitchName,
        [string]$ISOPath
    )
    
    Write-StatusMessage "Creating Ubuntu VM: $VMName..." -Type Info
    
    # Check if VM already exists
    $existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    if ($existingVM) {
        Write-StatusMessage "VM '$VMName' already exists. Skipping creation." -Type Warning
        return $existingVM
    }
    
    try {
        # Create VHD path for this VM
        $vhdFileName = "$VMName.vhdx"
        $vhdFullPath = Join-Path -Path $VHDPath -ChildPath $vhdFileName
        
        # Create new VHD
        Write-StatusMessage "Creating virtual disk ($($DiskSize / 1GB)GB)..." -Type Info
        New-VHD -Path $vhdFullPath -SizeBytes $DiskSize -Dynamic | Out-Null
        
        # Create Generation 2 VM (UEFI) for Ubuntu
        Write-StatusMessage "Creating Generation 2 VM..." -Type Info
        $vm = New-VM -Name $VMName `
                     -MemoryStartupBytes $MemorySize `
                     -Generation 2 `
                     -VHDPath $vhdFullPath `
                     -Path $VMPath `
                     -ErrorAction Stop
        
        # Configure VM settings
        Write-StatusMessage "Configuring VM settings..." -Type Info
        
        # Set processor count
        Set-VMProcessor -VMName $VMName -Count $ProcessorCount
        
        # Enable dynamic memory
        Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes ($MemorySize / 2) -MaximumBytes $MemorySize
        
        # Disable Secure Boot (required for Ubuntu compatibility)
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
        
        # Connect to virtual switch
        if (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue) {
            Get-VMNetworkAdapter -VMName $VMName | Connect-VMNetworkAdapter -SwitchName $SwitchName
            Write-StatusMessage "Connected to virtual switch: $SwitchName" -Type Success
        }
        else {
            Write-StatusMessage "Virtual switch '$SwitchName' not found. VM network adapter not connected." -Type Warning
        }
        
        # Add DVD drive and attach ISO
        if ($ISOPath -and (Test-Path $ISOPath)) {
            Write-StatusMessage "Attaching Ubuntu ISO to DVD drive..." -Type Info
            Add-VMDvdDrive -VMName $VMName -Path $ISOPath
            
            # Set boot order: DVD first, then HDD
            $dvdDrive = Get-VMDvdDrive -VMName $VMName
            $hardDrive = Get-VMHardDiskDrive -VMName $VMName
            Set-VMFirmware -VMName $VMName -BootOrder $dvdDrive, $hardDrive
            Write-StatusMessage "Boot order configured: DVD first, then HDD" -Type Success
        }
        else {
            Write-StatusMessage "ISO path not provided or not found. DVD drive not configured." -Type Warning
        }
        
        Write-StatusMessage "Ubuntu VM created successfully." -Type Success
        return $vm
    }
    catch {
        Write-StatusMessage "Error creating Ubuntu VM: $_" -Type Error
        return $null
    }
}

# Main execution
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Zero-Touch Hyper-V & Ubuntu VM Deployment" -ForegroundColor Cyan
Write-Host "  Windows Server 2022" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
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

Write-Host ""
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "  STEP 1: Hyper-V Installation" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

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
        
        if ($AutoRestart) {
            Write-StatusMessage "Auto-restart enabled. Restarting server in 30 seconds..." -Type Warning
            Write-StatusMessage "After restart, please run this script again to complete configuration." -Type Info
            Start-Sleep -Seconds 30
            Restart-Computer -Force
        }
        else {
            Write-StatusMessage "Please restart the server and run this script again to complete configuration." -Type Warning
            Write-StatusMessage "To enable automatic restart, use the -AutoRestart parameter." -Type Info
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
    
    # Create virtual switch
    if ($CreateExternalSwitch) {
        New-HyperVVirtualSwitch -SwitchName $VirtualSwitchName
    }
    
    # Configure firewall rules
    Set-HyperVFirewallRules
    
    Write-StatusMessage "Hyper-V configuration completed successfully." -Type Success
}
catch {
    Write-StatusMessage "Error during configuration: $_" -Type Error
    Write-StatusMessage "The Hyper-V module may not be available. Try restarting the server first." -Type Warning
    exit 1
}

# Deploy Ubuntu VM if requested
if ($DeployUbuntuVM) {
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Yellow
    Write-Host "  STEP 3: Ubuntu VM Deployment" -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Download Ubuntu ISO
    $isoFile = Get-UbuntuISO -ISOPath $ISOPath -ISOUrl $UbuntuISOUrl
    
    if ($isoFile) {
        # Create Ubuntu VM
        $ubuntuVM = New-UbuntuVM -VMName $UbuntuVMName `
                                  -VMPath $VMPath `
                                  -VHDPath $VHDPath `
                                  -MemorySize $UbuntuVMMemory `
                                  -DiskSize $UbuntuVMDiskSize `
                                  -ProcessorCount $UbuntuVMCPUCount `
                                  -SwitchName $VirtualSwitchName `
                                  -ISOPath $isoFile
        
        if ($ubuntuVM -and $AutoStartVM) {
            Write-StatusMessage "Starting Ubuntu VM..." -Type Info
            try {
                Start-VM -Name $UbuntuVMName -ErrorAction Stop
                Write-StatusMessage "Ubuntu VM started successfully." -Type Success
            }
            catch {
                Write-StatusMessage "Error starting VM: $_" -Type Warning
            }
        }
    }
    else {
        Write-StatusMessage "Ubuntu VM deployment skipped due to ISO download failure." -Type Warning
    }
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "  Zero-Touch Deployment Completed!" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Display summary
Write-StatusMessage "Deployment Summary:" -Type Info
Write-Host "  ✓ Hyper-V: Installed and configured"
Write-Host "  ✓ Storage Paths:"
Write-Host "    - VMs: $VMPath"
Write-Host "    - VHDs: $VHDPath"
Write-Host "    - ISOs: $ISOPath"
Write-Host "  ✓ Virtual Switch: $VirtualSwitchName"

if ($DeployUbuntuVM) {
    Write-Host "  ✓ Ubuntu VM: $UbuntuVMName"
    Write-Host "    - Memory: $($UbuntuVMMemory / 1GB)GB"
    Write-Host "    - Disk: $($UbuntuVMDiskSize / 1GB)GB"
    Write-Host "    - CPUs: $UbuntuVMCPUCount"
    Write-Host "    - Status: $(if ($AutoStartVM) { 'Started' } else { 'Created (not started)' })"
    
    Write-Host ""
    Write-StatusMessage "Next Steps:" -Type Info
    Write-Host "  1. Connect to VM using Hyper-V Manager or VMConnect:"
    Write-Host "     vmconnect.exe localhost '$UbuntuVMName'"
    Write-Host "  2. Complete Ubuntu installation wizard"
    Write-Host "  3. Configure network settings as needed"
}
else {
    Write-Host ""
    Write-StatusMessage "Next Steps:" -Type Info
    Write-Host "  1. Use Hyper-V Manager or PowerShell to create virtual machines"
    Write-Host "  2. Configure additional virtual switches as needed"
    Write-Host "  3. Set up VM replication if required"
}

Write-Host ""
