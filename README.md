# Modernization Scenarios

A collection of scripts, templates, and guides for infrastructure modernization scenarios, including virtualization, cloud migration, and server configuration automation.

## 📋 Overview

This repository contains automation scripts and documentation to help IT professionals modernize their infrastructure. The scenarios cover common tasks such as:

- **Hyper-V Deployment** - Automated installation and configuration of Hyper-V on Windows Server
- **Server Configuration** - PowerShell scripts for Windows Server setup and hardening
- **Migration Tools** - Scripts to assist with workload migration and modernization

## 🚀 Quick Start

### Prerequisites

- Windows Server 2022 (or Windows Server 2019)
- PowerShell 5.1 or later
- Administrator privileges
- Hardware virtualization enabled in BIOS/UEFI (for Hyper-V scenarios)

### Installation

1. Clone the repository:
   ```powershell
   git clone https://github.com/arthurclares/ModernizationScenarios.git
   cd ModernizationScenarios
   ```

2. Run scripts with appropriate permissions:
   ```powershell
   # Example: Install Hyper-V
   .\Scripts\Hyper-V\Install-ConfigureHyperV.ps1
   ```

## 🤖 Zero-Touch Deployment

This repository provides scripts for fully automated deployment with no user interaction required.

### Hyper-V Infrastructure Setup

**Script:** `Scripts/Hyper-V/Install-ConfigureHyperV.ps1`

Automated setup of Hyper-V infrastructure on Windows Server 2022:

```powershell
# Complete zero-touch deployment (default)
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1

# With automatic restart if Hyper-V installation requires it
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1 -AutoRestart
```

### What Happens Automatically:
1. ✅ Checks and installs Hyper-V if needed
2. ✅ Creates storage directories (VMs, VHDs, ISOs)
3. ✅ Configures Hyper-V host settings
4. ✅ Creates multiple virtual switches:
   - External switch (bound to physical adapter if available)
   - Internal switch (ALWAYS created as fallback)
   - Private switch (for isolated testing)
5. ✅ Configures firewall rules for Hyper-V

### Parameters for Customization
| Parameter | Default | Description |
|-----------|---------|-------------|
| `-VMPath` | `C:\Hyper-V\VMs` | Path for virtual machines |
| `-VHDPath` | `C:\Hyper-V\VHDs` | Path for virtual hard disks |
| `-ISOPath` | `C:\Hyper-V\ISOs` | Path for ISO files |
| `-ExternalSwitchName` | `External-vSwitch` | Name for the external virtual switch |
| `-InternalSwitchName` | `Internal-vSwitch` | Name for the internal virtual switch |
| `-AutoRestart` | `$false` | Automatically restart if Hyper-V installation requires it |

### Example Customizations
```powershell
# Custom storage paths
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1 -VMPath "D:\VMs" -VHDPath "D:\VHDs" -ISOPath "D:\ISOs"

# Custom switch names
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1 -ExternalSwitchName "Corp-vSwitch" -InternalSwitchName "Lab-vSwitch"
```

## 📁 Repository Structure

```
ModernizationScenarios/
├── Scripts/
│   ├── Hyper-V/
│   │   └── Install-ConfigureHyperV.ps1    # Hyper-V installation &amp; configuration
│   ├── Networking/
│   └── Storage/
├── Templates/
│   └── ARM/                                # Azure Resource Manager templates
├── Docs/
│   └── Guides/                             # Step-by-step documentation
└── README.md
```

## 📜 Available Scripts

### Hyper-V Installation and Configuration

**Script:** `Scripts/Hyper-V/Install-ConfigureHyperV.ps1`

Zero-touch automated setup of Hyper-V infrastructure on Windows Server 2022:

| Feature | Description |
|---------|-------------|
| Role Installation | Installs Hyper-V role with management tools |
| Storage Configuration | Creates default VM, VHD, and ISO directories |
| Virtual Networking | Creates multiple virtual switches for flexible networking |
| Host Settings | Configures Enhanced Session Mode and NUMA spanning |
| Firewall Rules | Enables required firewall rules |

**Virtual Switches Created:**
- **External-vSwitch** - Bound to physical network adapter (if available)
- **Internal-vSwitch** - ALWAYS created as fallback for VM networking
- **Private-vSwitch** - For isolated testing environments

**Usage:**
```powershell
# Zero-touch deployment (default)
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1

# With automatic restart
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1 -AutoRestart

# Custom storage paths
.\Scripts\Hyper-V\Install-ConfigureHyperV.ps1 -VMPath "D:\VMs" -VHDPath "D:\VHDs"
```

**Next Steps:**
After Hyper-V is installed, deploy Ubuntu VMs using the separate `Deploy-UbuntuVM.ps1` script.

### Ubuntu VM Deployment (Standalone)

**Script:** `Scripts/Hyper-V/Deploy-UbuntuVM.ps1`

Standalone zero-touch script to deploy Ubuntu VMs on an existing Hyper-V installation.

**Features:**
- Zero-touch deployment (no user prompts)
- Auto-downloads Ubuntu 22.04 or 24.04 LTS ISO
- Smart virtual switch detection
- Generation 2 UEFI VM optimized for Ubuntu
- Supports overwriting existing VMs with `-Force`

**Prerequisites:**
- Hyper-V must be installed and running
- Administrator privileges required

**Usage:**
```powershell
# Default deployment (Ubuntu 22.04, 4GB RAM, 2 CPUs, 50GB disk)
.\Scripts\Hyper-V\Deploy-UbuntuVM.ps1

# Custom configuration
.\Scripts\Hyper-V\Deploy-UbuntuVM.ps1 -VMName "WebServer" -Memory 8GB -CPUCount 4

# Deploy Ubuntu 24.04 LTS
.\Scripts\Hyper-V\Deploy-UbuntuVM.ps1 -UbuntuVersion 2404

# Overwrite existing VM
.\Scripts\Hyper-V\Deploy-UbuntuVM.ps1 -VMName "Ubuntu-Server" -Force
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-VMName` | String | `Ubuntu-Server` | Name for the VM |
| `-VMPath` | String | `C:\Hyper-V\VMs` | VM configuration storage path |
| `-VHDPath` | String | `C:\Hyper-V\VHDs` | Virtual hard disk storage path |
| `-ISOPath` | String | `C:\Hyper-V\ISOs` | ISO file storage path |
| `-Memory` | Long | `4GB` | Memory allocation |
| `-DiskSize` | Long | `50GB` | Virtual disk size |
| `-CPUCount` | Int | `2` | Number of virtual CPUs |
| `-SwitchName` | String | (auto-detect) | Virtual switch name |
| `-UbuntuVersion` | String | `2204` | Ubuntu version (2204 or 2404) |
| `-AutoStart` | Switch | `$true` | Start VM after creation |
| `-Force` | Switch | `$false` | Overwrite existing VM with same name |

## 🔧 Configuration

### Default Settings

The scripts use sensible defaults that can be customized:

```powershell
# Hyper-V defaults
$VMPath = "C:\Hyper-V\VMs"
$VHDPath = "C:\Hyper-V\VHDs"
$VirtualSwitchName = "External-vSwitch"
```

### Environment Variables

You can also set environment variables for persistent configuration:

```powershell
[Environment]::SetEnvironmentVariable("HYPERV_VM_PATH", "D:\VMs", "Machine")
[Environment]::SetEnvironmentVariable("HYPERV_VHD_PATH", "D:\VHDs", "Machine")
```

## ✅ Requirements

### Hardware Requirements (for Hyper-V)

- 64-bit processor with Second Level Address Translation (SLAT)
- CPU support for VM Monitor Mode Extension (VT-x on Intel / AMD-V on AMD)
- Minimum 4 GB RAM (8 GB or more recommended)
- Hardware virtualization enabled in BIOS/UEFI

### Software Requirements

- Windows Server 2022 or Windows Server 2019
- PowerShell 5.1 or later
- .NET Framework 4.7.2 or later

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-scenario`)
3. Commit your changes (`git commit -am 'Add new modernization scenario'`)
4. Push to the branch (`git push origin feature/new-scenario`)
5. Open a Pull Request

### Coding Standards

- Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)
- Include comment-based help for all functions
- Add error handling with try/catch blocks
- Test scripts on Windows Server 2022 before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Arthur Clares**
- GitHub: [@arthurclares](https://github.com/arthurclares)

## 🙏 Acknowledgments

- Microsoft Documentation for PowerShell and Hyper-V
- The PowerShell community for best practices and patterns

---

⭐ If you find this repository helpful, please consider giving it a star!
