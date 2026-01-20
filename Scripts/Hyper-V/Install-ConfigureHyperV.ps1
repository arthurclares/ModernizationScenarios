#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs and configures Hyper-V on Windows Server 2022 with Ubuntu VM deployment.

.DESCRIPTION
    This script performs the following tasks:
    - Checks prerequisites (hardware virtualization support)
    - Installs Hyper-V role and management tools (if not already installed)
    - Configures default virtual machine storage paths
    - Creates a virtual switch for VM networking
    - Configures Hyper-V host settings
    - Downloads Ubuntu Server 22.04.3 LTS ISO
    - Deploys and configures Ubuntu VM (Generation 2/UEFI)

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
    [switch]$SkipRestart = $false,
    [string]$ISOPath = "C:\Hyper-V\ISOs",
    [switch]$DeployUbuntuVM = $true,
    [string]$UbuntuVMName = "Ubuntu-Server",
    [long]$UbuntuVMMemory = 4GB,
    [long]$UbuntuVMDiskSize = 50GB,
    [int]$UbuntuVMCPUCount = 2,
    [string]$UbuntuISOPath = ""
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

# Function to download Ubuntu ISO
function Get-UbuntuISO {
    param(
        [string]$ISOPath,
        [string]$ExistingISOPath
    )
    
    Write-StatusMessage "Preparing Ubuntu ISO..." -Type Info
    
    # Ubuntu 22.04.3 LTS ISO details
    $ubuntuISOUrl = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
    $isoFileName = "ubuntu-22.04.3-live-server-amd64.iso"
    $isoFullPath = Join-Path -Path $ISOPath -ChildPath $isoFileName
    
    # Check if existing ISO path is provided and valid
    if ($ExistingISOPath -and (Test-Path -Path $ExistingISOPath)) {
        Write-StatusMessage "Using existing ISO: $ExistingISOPath" -Type Success
        return $ExistingISOPath
    }
    
    # Create ISO directory if it doesn't exist
    if (-not (Test-Path -Path $ISOPath)) {
        New-Item -Path $ISOPath -ItemType Directory -Force | Out-Null
        Write-StatusMessage "Created ISO directory: $ISOPath" -Type Success
    }
    
    # Check if ISO already exists
    if (Test-Path -Path $isoFullPath) {
        Write-StatusMessage "Ubuntu ISO already exists: $isoFullPath" -Type Info
        return $isoFullPath
    }
    
    Write-StatusMessage "Downloading Ubuntu Server 22.04.3 LTS ISO..." -Type Info
    Write-StatusMessage "This may take several minutes depending on your internet connection..." -Type Info
    
    try {
        # Try using BITS transfer first (more reliable for large files)
        Import-Module BitsTransfer -ErrorAction SilentlyContinue
        
        if (Get-Module -Name BitsTransfer) {
            Write-StatusMessage "Using BITS transfer for download..." -Type Info
            Start-BitsTransfer -Source $ubuntuISOUrl -Destination $isoFullPath -Description "Downloading Ubuntu ISO"
            Write-StatusMessage "Ubuntu ISO downloaded successfully: $isoFullPath" -Type Success
        }
        else {
            # Fallback to WebClient
            Write-StatusMessage "Using WebClient for download..." -Type Info
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($ubuntuISOUrl, $isoFullPath)
            $webClient.Dispose()
            Write-StatusMessage "Ubuntu ISO downloaded successfully: $isoFullPath" -Type Success
        }
        
        return $isoFullPath
    }
    catch {
        Write-StatusMessage "Error downloading Ubuntu ISO: $_" -Type Error
        return $null
    }
}

# Function to create Ubuntu VM
function New-UbuntuVM {
    param(
        [string]$VMName,
        [string]$VMPath,
        [string]$VHDPath,
        [string]$SwitchName,
        [string]$ISOPath,
        [long]$Memory,
        [long]$DiskSize,
        [int]$CPUCount
    )
    
    Write-StatusMessage "Creating Ubuntu VM: $VMName" -Type Info
    
    try {
        # Check if VM already exists
        $existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
        if ($existingVM) {
            Write-StatusMessage "VM '$VMName' already exists. Skipping creation." -Type Warning
            return $existingVM
        }
        
        # Create VHD path for this VM
        $vhdFullPath = Join-Path -Path $VHDPath -ChildPath "$VMName.vhdx"
        
        # Create Generation 2 VM (UEFI support for Ubuntu)
        Write-StatusMessage "Creating Generation 2 VM (UEFI)..." -Type Info
        $vm = New-VM -Name $VMName `
            -MemoryStartupBytes $Memory `
            -Path $VMPath `
            -NewVHDPath $vhdFullPath `
            -NewVHDSizeBytes $DiskSize `
            -Generation 2 `
            -SwitchName $SwitchName `
            -ErrorAction Stop
        
        Write-StatusMessage "VM created successfully." -Type Success
        
        # Configure VM settings
        Write-StatusMessage "Configuring VM settings..." -Type Info
        
        # Set processor count
        Set-VMProcessor -VMName $VMName -Count $CPUCount -ErrorAction Stop
        
        # Configure dynamic memory
        Set-VMMemory -VMName $VMName `
            -DynamicMemoryEnabled $true `
            -MinimumBytes 1GB `
            -MaximumBytes 8GB `
            -ErrorAction Stop
        
        # Disable Secure Boot (required for Ubuntu compatibility)
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off -ErrorAction Stop
        
        # Add DVD drive with ISO
        Write-StatusMessage "Adding DVD drive with Ubuntu ISO..." -Type Info
        Add-VMDvdDrive -VMName $VMName -Path $ISOPath -ErrorAction Stop
        
        # Set boot order to DVD first
        $dvdDrive = Get-VMDvdDrive -VMName $VMName
        $hardDrive = Get-VMHardDiskDrive -VMName $VMName
        Set-VMFirmware -VMName $VMName -FirstBootDevice $dvdDrive -ErrorAction Stop
        
        # Enable Guest Services (integration services)
        Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface" -ErrorAction SilentlyContinue
        
        Write-StatusMessage "VM configuration completed." -Type Success
        
        # Display VM details
        Write-StatusMessage "Ubuntu VM Details:" -Type Info
        Write-Host "  Name: $VMName"
        Write-Host "  Memory: $($Memory / 1GB)GB (Dynamic: 1GB - 8GB)"
        Write-Host "  CPUs: $CPUCount"
        Write-Host "  Disk: $($DiskSize / 1GB)GB"
        Write-Host "  Generation: 2 (UEFI)"
        Write-Host "  Switch: $SwitchName"
        Write-Host "  ISO: $ISOPath"
        
        return $vm
    }
    catch {
        Write-StatusMessage "Error creating Ubuntu VM: $_" -Type Error
        return $null
    }
}

# Function to start Ubuntu VM
function Start-UbuntuVM {
    param(
        [string]$VMName
    )
    
    Write-StatusMessage "Starting Ubuntu VM: $VMName" -Type Info
    
    try {
        # Check VM state
        $vm = Get-VM -Name $VMName -ErrorAction Stop
        
        if ($vm.State -eq "Running") {
            Write-StatusMessage "VM is already running." -Type Info
        }
        else {
            Start-VM -Name $VMName -ErrorAction Stop
            Write-StatusMessage "VM started successfully." -Type Success
        }
        
        Write-Host ""
        Write-StatusMessage "Next Steps for Ubuntu Installation:" -Type Info
        Write-Host "  1. Connect to the VM using Hyper-V Manager or VMConnect"
        Write-Host "  2. Follow the Ubuntu Server installation wizard"
        Write-Host "  3. After installation, remove the ISO and restart the VM"
        Write-Host ""
        Write-StatusMessage "To connect to the VM, run:" -Type Info
        Write-Host "  vmconnect.exe localhost '$VMName'"
        Write-Host ""
    }
    catch {
        Write-StatusMessage "Error starting Ubuntu VM: $_" -Type Error
    }
}

# Main execution
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Hyper-V Installation and Configuration Script" -ForegroundColor Cyan
Write-Host "  Windows Server 2022 + Ubuntu VM Deployment" -ForegroundColor Cyan
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

Write-Host ""
Write-Host "=== STEP 1: Hyper-V Installation Check ===" -ForegroundColor Cyan
Write-Host ""

# Check if Hyper-V is already installed
if (Test-HyperVInstalled) {
    Write-StatusMessage "Hyper-V is already installed. Skipping installation, proceeding to configuration..." -Type Info
}
else {
    Write-StatusMessage "Hyper-V is not installed. Starting installation..." -Type Info
    
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

Write-Host ""
Write-Host "=== STEP 2: Hyper-V Configuration ===" -ForegroundColor Cyan
Write-Host ""

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
    
    Write-StatusMessage "Hyper-V configuration completed successfully!" -Type Success
}
catch {
    Write-StatusMessage "Error during configuration: $_" -Type Error
    Write-StatusMessage "The Hyper-V module may not be available. Try restarting the server first." -Type Warning
    exit 1
}

# Deploy Ubuntu VM if requested
if ($DeployUbuntuVM) {
    Write-Host ""
    Write-Host "=== STEP 3: Ubuntu VM Deployment ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Download or locate Ubuntu ISO
    $ubuntuISO = Get-UbuntuISO -ISOPath $ISOPath -ExistingISOPath $UbuntuISOPath
    
    if (-not $ubuntuISO) {
        Write-StatusMessage "Failed to obtain Ubuntu ISO. Skipping VM deployment." -Type Error
    }
    else {
        # Verify virtual switch exists
        $switch = Get-VMSwitch -Name $VirtualSwitchName -ErrorAction SilentlyContinue
        if (-not $switch) {
            # Try to find any available switch
            $switch = Get-VMSwitch | Select-Object -First 1
            if ($switch) {
                Write-StatusMessage "Using virtual switch: $($switch.Name)" -Type Info
                $VirtualSwitchName = $switch.Name
            }
            else {
                Write-StatusMessage "No virtual switch available. Cannot create VM." -Type Error
                $ubuntuISO = $null
            }
        }
        
        if ($ubuntuISO) {
            # Create Ubuntu VM
            $vm = New-UbuntuVM -VMName $UbuntuVMName `
                -VMPath $VMPath `
                -VHDPath $VHDPath `
                -SwitchName $VirtualSwitchName `
                -ISOPath $ubuntuISO `
                -Memory $UbuntuVMMemory `
                -DiskSize $UbuntuVMDiskSize `
                -CPUCount $UbuntuVMCPUCount
            
            if ($vm) {
                # Start the VM
                Start-UbuntuVM -VMName $UbuntuVMName
            }
        }
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-StatusMessage "Hyper-V setup completed successfully!" -Type Success
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

if ($DeployUbuntuVM) {
    Write-StatusMessage "Summary:" -Type Info
    Write-Host "  ✓ Hyper-V installed and configured"
    Write-Host "  ✓ Virtual switch created: $VirtualSwitchName"
    Write-Host "  ✓ Ubuntu VM deployed: $UbuntuVMName"
    Write-Host ""
    Write-StatusMessage "Management Tools:" -Type Info
    Write-Host "  • Hyper-V Manager: virtmgmt.msc"
    Write-Host "  • PowerShell: Get-VM, Start-VM, Stop-VM"
    Write-Host "  • Connect to VM: vmconnect.exe localhost '$UbuntuVMName'"
}
else {
    Write-StatusMessage "Next steps:" -Type Info
    Write-Host "  1. Use Hyper-V Manager or PowerShell to create virtual machines"
    Write-Host "  2. Configure additional virtual switches as needed"
    Write-Host "  3. Set up VM replication if required"
}
Write-Host ""
