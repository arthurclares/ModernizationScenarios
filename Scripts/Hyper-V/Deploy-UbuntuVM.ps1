#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Standalone zero-touch script for deploying Ubuntu Server VMs on Hyper-V.

.DESCRIPTION
    This script deploys Ubuntu Server VMs on an existing Hyper-V installation with NO user interaction required.
    It performs the following tasks automatically:
    - Validates Hyper-V is installed and running
    - Auto-detects available virtual switches (prefers external over internal)
    - Downloads Ubuntu Server ISO (22.04 or 24.04 LTS) automatically
    - Creates Generation 2 (UEFI) VM optimized for Ubuntu
    - Configures dynamic memory, disables Secure Boot, attaches ISO
    - Starts the VM automatically (optional)
    
    This script does NOT install Hyper-V - it assumes Hyper-V is already installed and configured.

.PARAMETER VMName
    Name for the virtual machine. Default: "Ubuntu-Server"

.PARAMETER VMPath
    Path where VM configuration files will be stored. Default: "C:\Hyper-V\VMs"

.PARAMETER VHDPath
    Path where virtual hard disk files will be stored. Default: "C:\Hyper-V\VHDs"

.PARAMETER ISOPath
    Path where ISO files will be downloaded and stored. Default: "C:\Hyper-V\ISOs"

.PARAMETER Memory
    Memory allocation for the VM in bytes. Supports units like GB. Default: 4GB

.PARAMETER DiskSize
    Virtual disk size in bytes. Supports units like GB. Default: 50GB

.PARAMETER CPUCount
    Number of virtual processors to assign to the VM. Default: 2

.PARAMETER SwitchName
    Name of the virtual switch to connect the VM to. If not specified, auto-detects available switches.

.PARAMETER UbuntuVersion
    Ubuntu version to deploy. Valid values: "2204" (22.04 LTS) or "2404" (24.04 LTS). Default: "2204"

.PARAMETER AutoStart
    Automatically start the VM after creation. Enabled by default. Use -AutoStart:$false to disable.

.PARAMETER Force
    Force overwrite if a VM with the same name already exists.

.EXAMPLE
    .\Deploy-UbuntuVM.ps1
    
    Deploys Ubuntu Server 22.04 LTS with default settings (4GB RAM, 2 CPUs, 50GB disk).

.EXAMPLE
    .\Deploy-UbuntuVM.ps1 -VMName "WebServer" -Memory 8GB -CPUCount 4
    
    Deploys Ubuntu Server with custom VM name and increased resources.

.EXAMPLE
    .\Deploy-UbuntuVM.ps1 -VMName "Ubuntu2404" -UbuntuVersion 2404
    
    Deploys Ubuntu Server 24.04 LTS instead of the default 22.04.

.EXAMPLE
    .\Deploy-UbuntuVM.ps1 -VMName "Ubuntu-Server" -Force
    
    Overwrites existing VM with the same name if it exists.

.NOTES
    Author: Arthur Clares
    Date: 2026-01-21
    Repository: https://github.com/arthurclares/ModernizationScenarios
    Requires: Hyper-V installed and running, Administrator privileges
    Zero-Touch: No user prompts - fully automated operation
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$VMName = "Ubuntu-Server",
    
    [string]$VMPath = "C:\Hyper-V\VMs",
    
    [string]$VHDPath = "C:\Hyper-V\VHDs",
    
    [string]$ISOPath = "C:\Hyper-V\ISOs",
    
    [long]$Memory = 4GB,
    
    [long]$DiskSize = 50GB,
    
    [int]$CPUCount = 2,
    
    [string]$SwitchName = "",
    
    [ValidateSet("2204", "2404")]
    [string]$UbuntuVersion = "2204",
    
    [switch]$AutoStart,
    
    [switch]$Force
)

# Constants
$script:MinimumISOSizeGB = 1

# Ubuntu ISO configuration
$UbuntuISOs = @{
    "2204" = @{
        Url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
        FileName = "ubuntu-22.04.5-live-server-amd64.iso"
        DisplayName = "Ubuntu Server 22.04.5 LTS"
    }
    "2404" = @{
        Url = "https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso"
        FileName = "ubuntu-24.04.1-live-server-amd64.iso"
        DisplayName = "Ubuntu Server 24.04.1 LTS"
    }
}

#region Helper Functions

function Write-Log {
    <#
    .SYNOPSIS
        Writes timestamped colored log messages.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colors = @{
        "INFO"    = "Cyan"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR"   = "Red"
    }
    
    $prefix = "[$timestamp] [$Level]"
    Write-Host "$prefix $Message" -ForegroundColor $colors[$Level]
}

function Test-HyperVAvailable {
    <#
    .SYNOPSIS
        Validates that Hyper-V is available and running.
    #>
    Write-Log "Checking Hyper-V availability..." -Level INFO
    
    # Check if Hyper-V module is available
    $hyperVModule = Get-Module -ListAvailable -Name Hyper-V
    if (-not $hyperVModule) {
        Write-Log "Hyper-V PowerShell module is not available. Please install Hyper-V first." -Level ERROR
        return $false
    }
    
    # Import the module
    try {
        Import-Module Hyper-V -ErrorAction Stop
        Write-Log "Hyper-V module loaded successfully." -Level SUCCESS
    }
    catch {
        Write-Log "Failed to load Hyper-V module: $_" -Level ERROR
        return $false
    }
    
    # Check if VMMS service is running
    $vmmsService = Get-Service -Name vmms -ErrorAction SilentlyContinue
    if (-not $vmmsService) {
        Write-Log "Hyper-V Virtual Machine Management Service (VMMS) is not installed." -Level ERROR
        return $false
    }
    
    if ($vmmsService.Status -ne "Running") {
        Write-Log "Hyper-V Virtual Machine Management Service is not running. Status: $($vmmsService.Status)" -Level ERROR
        return $false
    }
    
    Write-Log "Hyper-V is available and running." -Level SUCCESS
    return $true
}

function Initialize-Directories {
    <#
    .SYNOPSIS
        Creates storage directories if they don't exist.
    #>
    param(
        [string]$VMPath,
        [string]$VHDPath,
        [string]$ISOPath
    )
    
    Write-Log "Initializing storage directories..." -Level INFO
    
    $paths = @{
        "VM Configuration" = $VMPath
        "Virtual Hard Disk" = $VHDPath
        "ISO Files" = $ISOPath
    }
    
    foreach ($pathType in $paths.Keys) {
        $path = $paths[$pathType]
        if (-not (Test-Path -Path $path)) {
            try {
                New-Item -Path $path -ItemType Directory -Force | Out-Null
                Write-Log "Created $pathType directory: $path" -Level SUCCESS
            }
            catch {
                Write-Log "Failed to create $pathType directory: $_" -Level ERROR
                throw
            }
        }
        else {
            Write-Log "$pathType directory exists: $path" -Level INFO
        }
    }
}

function Get-AvailableVMSwitch {
    <#
    .SYNOPSIS
        Auto-detects available virtual switches, prefers external over internal.
    #>
    param(
        [string]$PreferredSwitchName
    )
    
    Write-Log "Detecting available virtual switches..." -Level INFO
    
    # If a specific switch is requested, verify it exists
    if ($PreferredSwitchName) {
        $switch = Get-VMSwitch -Name $PreferredSwitchName -ErrorAction SilentlyContinue
        if ($switch) {
            Write-Log "Using specified switch: $PreferredSwitchName (Type: $($switch.SwitchType))" -Level SUCCESS
            return $PreferredSwitchName
        }
        else {
            Write-Log "Specified switch '$PreferredSwitchName' not found. Auto-detecting..." -Level WARNING
        }
    }
    
    # Get all available switches
    $allSwitches = Get-VMSwitch
    
    if ($allSwitches.Count -eq 0) {
        Write-Log "No virtual switches found. Please create a virtual switch first." -Level ERROR
        throw "No virtual switches available"
    }
    
    # Prefer external switches
    $externalSwitch = $allSwitches | Where-Object { $_.SwitchType -eq "External" } | Select-Object -First 1
    if ($externalSwitch) {
        Write-Log "Auto-detected external switch: $($externalSwitch.Name)" -Level SUCCESS
        return $externalSwitch.Name
    }
    
    # Fall back to internal switches
    $internalSwitch = $allSwitches | Where-Object { $_.SwitchType -eq "Internal" } | Select-Object -First 1
    if ($internalSwitch) {
        Write-Log "Auto-detected internal switch: $($internalSwitch.Name)" -Level SUCCESS
        return $internalSwitch.Name
    }
    
    # Use any available switch as last resort
    $anySwitch = $allSwitches | Select-Object -First 1
    Write-Log "Using available switch: $($anySwitch.Name) (Type: $($anySwitch.SwitchType))" -Level SUCCESS
    return $anySwitch.Name
}

function Get-UbuntuISO {
    <#
    .SYNOPSIS
        Downloads Ubuntu ISO using BITS transfer with WebClient fallback.
    #>
    param(
        [hashtable]$ISOInfo,
        [string]$DestinationPath
    )
    
    $isoFile = Join-Path -Path $DestinationPath -ChildPath $ISOInfo.FileName
    
    # Check if ISO already exists and is valid
    if (Test-Path -Path $isoFile) {
        $fileInfo = Get-Item -Path $isoFile
        if ($fileInfo.Length -gt ($script:MinimumISOSizeGB * 1GB)) {
            Write-Log "ISO file already exists and appears valid: $isoFile ($([math]::Round($fileInfo.Length / 1GB, 2)) GB)" -Level SUCCESS
            return $isoFile
        }
        else {
            Write-Log "Existing ISO file is too small, will re-download." -Level WARNING
            Remove-Item -Path $isoFile -Force
        }
    }
    
    Write-Log "Downloading $($ISOInfo.DisplayName)..." -Level INFO
    Write-Log "Source: $($ISOInfo.Url)" -Level INFO
    Write-Log "Destination: $isoFile" -Level INFO
    
    $downloadSuccess = $false
    
    # Try BITS transfer first
    try {
        Write-Log "Attempting download using BITS transfer..." -Level INFO
        Start-BitsTransfer -Source $ISOInfo.Url -Destination $isoFile -Description "Downloading $($ISOInfo.DisplayName)" -ErrorAction Stop
        $downloadSuccess = $true
        Write-Log "Download completed successfully using BITS." -Level SUCCESS
    }
    catch {
        Write-Log "BITS transfer failed: $_" -Level WARNING
        Write-Log "Falling back to WebClient..." -Level INFO
        
        # Fall back to WebClient (deprecated but still supported for compatibility)
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($ISOInfo.Url, $isoFile)
            $downloadSuccess = $true
            Write-Log "Download completed successfully using WebClient." -Level SUCCESS
        }
        catch {
            Write-Log "WebClient download failed: $_" -Level ERROR
            throw "Failed to download ISO file"
        }
        finally {
            if ($webClient) {
                $webClient.Dispose()
            }
        }
    }
    
    # Validate downloaded file size
    if ($downloadSuccess) {
        $fileInfo = Get-Item -Path $isoFile
        if ($fileInfo.Length -gt ($script:MinimumISOSizeGB * 1GB)) {
            Write-Log "ISO file validated: $([math]::Round($fileInfo.Length / 1GB, 2)) GB" -Level SUCCESS
            return $isoFile
        }
        else {
            Write-Log "Downloaded file is too small ($([math]::Round($fileInfo.Length / 1MB, 2)) MB). Expected > $script:MinimumISOSizeGB GB." -Level ERROR
            Remove-Item -Path $isoFile -Force -ErrorAction SilentlyContinue
            throw "Downloaded ISO file failed size validation"
        }
    }
    
    throw "Failed to download ISO file"
}

function Remove-ExistingVM {
    <#
    .SYNOPSIS
        Removes existing VM and VHD when -Force parameter is used.
    #>
    param(
        [string]$VMName,
        [string]$VHDPath
    )
    
    Write-Log "Removing existing VM: $VMName" -Level WARNING
    
    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    if (-not $vm) {
        return
    }
    
    # Stop VM if running
    if ($vm.State -eq "Running") {
        Write-Log "Stopping VM..." -Level INFO
        Stop-VM -Name $VMName -Force -TurnOff
    }
    
    # Get VHD paths before removing VM
    $vhdPaths = @()
    $vmHardDrives = Get-VMHardDiskDrive -VMName $VMName -ErrorAction SilentlyContinue
    foreach ($hdd in $vmHardDrives) {
        if ($hdd.Path) {
            $vhdPaths += $hdd.Path
        }
    }
    
    # Remove VM
    Remove-VM -Name $VMName -Force
    Write-Log "VM removed successfully." -Level SUCCESS
    
    # Remove VHD files
    foreach ($vhdPath in $vhdPaths) {
        if (Test-Path -Path $vhdPath) {
            try {
                Remove-Item -Path $vhdPath -Force
                Write-Log "Removed VHD: $vhdPath" -Level SUCCESS
            }
            catch {
                Write-Log "Failed to remove VHD: $vhdPath - $_" -Level WARNING
            }
        }
    }
}

function New-UbuntuVirtualMachine {
    <#
    .SYNOPSIS
        Creates Generation 2 VM with all configurations.
    #>
    param(
        [string]$VMName,
        [string]$VMPath,
        [string]$VHDPath,
        [string]$ISOPath,
        [long]$Memory,
        [long]$DiskSize,
        [int]$CPUCount,
        [string]$SwitchName
    )
    
    Write-Log "Creating Ubuntu VM: $VMName" -Level INFO
    
    # Create VHD path
    $vhdFile = Join-Path -Path $VHDPath -ChildPath "$VMName.vhdx"
    
    try {
        # Create Generation 2 VM
        Write-Log "Creating Generation 2 (UEFI) VM..." -Level INFO
        $vm = New-VM -Name $VMName `
                     -MemoryStartupBytes $Memory `
                     -Generation 2 `
                     -Path $VMPath `
                     -NewVHDPath $vhdFile `
                     -NewVHDSizeBytes $DiskSize `
                     -SwitchName $SwitchName `
                     -ErrorAction Stop
        
        Write-Log "VM created successfully." -Level SUCCESS
        
        # Configure dynamic memory
        Write-Log "Configuring dynamic memory..." -Level INFO
        Set-VMMemory -VMName $VMName `
                     -DynamicMemoryEnabled $true `
                     -MinimumBytes 1GB `
                     -StartupBytes $Memory `
                     -MaximumBytes ($Memory * 2) `
                     -ErrorAction Stop
        
        # Set processor count
        Write-Log "Setting CPU count to $CPUCount..." -Level INFO
        Set-VMProcessor -VMName $VMName -Count $CPUCount -ErrorAction Stop
        
        # Disable Secure Boot (required for Ubuntu)
        Write-Log "Disabling Secure Boot for Ubuntu compatibility..." -Level INFO
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off -ErrorAction Stop
        
        # Add DVD drive and attach ISO
        Write-Log "Adding DVD drive and attaching ISO..." -Level INFO
        Add-VMDvdDrive -VMName $VMName -Path $ISOPath -ErrorAction Stop
        
        # Set boot order: DVD first, then HDD
        Write-Log "Configuring boot order (DVD first)..." -Level INFO
        $dvdDrive = Get-VMDvdDrive -VMName $VMName
        $hardDrive = Get-VMHardDiskDrive -VMName $VMName
        Set-VMFirmware -VMName $VMName -FirstBootDevice $dvdDrive -ErrorAction Stop
        
        # Enable Guest Service Interface
        Write-Log "Enabling Guest Service Interface..." -Level INFO
        Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface" -ErrorAction Stop
        
        # Set checkpoint type to standard
        Write-Log "Setting checkpoint type to Standard..." -Level INFO
        Set-VM -VMName $VMName -CheckpointType Standard -ErrorAction Stop
        
        Write-Log "VM configuration completed successfully." -Level SUCCESS
        
        return $vm
    }
    catch {
        Write-Log "Failed to create VM: $_" -Level ERROR
        throw
    }
}

function Show-VMSummary {
    <#
    .SYNOPSIS
        Displays formatted summary of created VM.
    #>
    param(
        [string]$VMName,
        [string]$UbuntuVersion,
        [string]$ISOPath
    )
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "    VM Deployment Summary" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    $vm = Get-VM -Name $VMName
    $vmMemory = Get-VMMemory -VMName $VMName
    $vmProcessor = Get-VMProcessor -VMName $VMName
    $vmNetAdapter = Get-VMNetworkAdapter -VMName $VMName
    $vmHardDrive = Get-VMHardDiskDrive -VMName $VMName
    
    Write-Host "VM Name:              " -NoNewline
    Write-Host $vm.Name -ForegroundColor Cyan
    
    Write-Host "State:                " -NoNewline
    $stateColor = if ($vm.State -eq "Running") { "Green" } else { "Yellow" }
    Write-Host $vm.State -ForegroundColor $stateColor
    
    Write-Host "Generation:           " -NoNewline
    Write-Host "2 (UEFI)" -ForegroundColor Cyan
    
    Write-Host "Ubuntu Version:       " -NoNewline
    Write-Host $UbuntuISOs[$UbuntuVersion].DisplayName -ForegroundColor Cyan
    
    Write-Host "Memory:               " -NoNewline
    Write-Host "$([math]::Round($vmMemory.Startup / 1GB, 2)) GB (Dynamic: $($vmMemory.DynamicMemoryEnabled))" -ForegroundColor Cyan
    
    Write-Host "Processors:           " -NoNewline
    Write-Host $vmProcessor.Count -ForegroundColor Cyan
    
    Write-Host "Virtual Switch:       " -NoNewline
    Write-Host $vmNetAdapter.SwitchName -ForegroundColor Cyan
    
    Write-Host "Virtual Disk:         " -NoNewline
    Write-Host "$($vmHardDrive.Path) ($([math]::Round((Get-VHD -Path $vmHardDrive.Path).Size / 1GB, 2)) GB)" -ForegroundColor Cyan
    
    Write-Host "ISO Attached:         " -NoNewline
    Write-Host $ISOPath -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Connection Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Open Hyper-V Manager or run: " -NoNewline
    Write-Host "vmconnect.exe localhost `"$VMName`"" -ForegroundColor Cyan
    Write-Host "  2. Complete Ubuntu Server installation" -ForegroundColor White
    Write-Host "  3. After installation, remove ISO and restart VM" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
}

#endregion

#region Main Script

# Display banner
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Ubuntu VM Deployment for Hyper-V" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Log "This script requires Administrator privileges. Please run as Administrator." -Level ERROR
    exit 1
}

Write-Log "Administrator privileges confirmed." -Level SUCCESS

# Validate Hyper-V is available
if (-not (Test-HyperVAvailable)) {
    Write-Log "Hyper-V is not available. Please install Hyper-V first." -Level ERROR
    exit 1
}

# Check for existing VM
$existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if ($existingVM) {
    if ($Force) {
        Write-Log "VM '$VMName' already exists. Force flag specified, removing existing VM..." -Level WARNING
        Remove-ExistingVM -VMName $VMName -VHDPath $VHDPath
    }
    else {
        Write-Log "VM '$VMName' already exists. Use -Force to overwrite." -Level ERROR
        exit 1
    }
}

# Initialize storage directories
Initialize-Directories -VMPath $VMPath -VHDPath $VHDPath -ISOPath $ISOPath

# Auto-detect or validate virtual switch
try {
    $selectedSwitch = Get-AvailableVMSwitch -PreferredSwitchName $SwitchName
}
catch {
    Write-Log "Failed to detect virtual switch: $_" -Level ERROR
    exit 1
}

# Download Ubuntu ISO
$ubuntuISO = $UbuntuISOs[$UbuntuVersion]
try {
    $isoFilePath = Get-UbuntuISO -ISOInfo $ubuntuISO -DestinationPath $ISOPath
}
catch {
    Write-Log "Failed to download Ubuntu ISO: $_" -Level ERROR
    exit 1
}

# Create VM
try {
    $newVM = New-UbuntuVirtualMachine -VMName $VMName `
                                       -VMPath $VMPath `
                                       -VHDPath $VHDPath `
                                       -ISOPath $isoFilePath `
                                       -Memory $Memory `
                                       -DiskSize $DiskSize `
                                       -CPUCount $CPUCount `
                                       -SwitchName $selectedSwitch
}
catch {
    Write-Log "Failed to create VM: $_" -Level ERROR
    exit 1
}

# Start VM if AutoStart is enabled (default behavior unless -AutoStart:$false is specified)
if (-not $PSBoundParameters.ContainsKey('AutoStart')) {
    # Default to auto-start if not explicitly specified
    $AutoStart = $true
}

if ($AutoStart) {
    Write-Log "Starting VM..." -Level INFO
    try {
        Start-VM -Name $VMName -ErrorAction Stop
        Write-Log "VM started successfully." -Level SUCCESS
    }
    catch {
        Write-Log "Failed to start VM: $_" -Level WARNING
    }
}
else {
    Write-Log "AutoStart is disabled. VM created but not started." -Level INFO
}

# Display summary
Show-VMSummary -VMName $VMName -UbuntuVersion $UbuntuVersion -ISOPath $isoFilePath

Write-Log "Ubuntu VM deployment completed successfully!" -Level SUCCESS

#endregion
