# Modernization Scenarios

A collection of scripts, templates, and guides for infrastructure modernization scenarios, including virtualization, cloud migration, and server configuration automation.

## 📋 Overview

This repository contains automation scripts and documentation to help IT professionals modernize their infrastructure. The scenarios cover common tasks such as:

- **Hyper-V Deployment** - Automated installation and configuration of Hyper-V on Windows Server with Ubuntu VM deployment
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

Automates the complete setup of Hyper-V on Windows Server 2022, including Ubuntu VM deployment:

| Feature | Description |
|---------|-------------|
| Smart Installation | Checks if Hyper-V is installed, skips installation if already present |
| Role Installation | Installs Hyper-V role with management tools (if needed) |
| Storage Configuration | Creates default VM, VHD, and ISO directories |
| Virtual Networking | Creates external virtual switch |
| Host Settings | Configures Enhanced Session Mode and NUMA spanning |
| Firewall Rules | Enables required firewall rules |
| Ubuntu ISO Download | Automatically downloads Ubuntu Server 22.04.3 LTS ISO |
| Ubuntu VM Deployment | Creates and configures Generation 2 (UEFI) Ubuntu VM |

**Usage:**
```powershell
# Full deployment with defaults (includes Ubuntu VM)
.\Install-ConfigureHyperV.ps1

# Custom VM specifications
.\Install-ConfigureHyperV.ps1 -UbuntuVMName "WebServer-Ubuntu" -UbuntuVMMemory 8GB -UbuntuVMCPUCount 4

# Custom paths for storage
.\Install-ConfigureHyperV.ps1 -VMPath "D:\VMs" -VHDPath "D:\VHDs" -ISOPath "D:\ISOs"

# Use existing Ubuntu ISO
.\Install-ConfigureHyperV.ps1 -UbuntuISOPath "D:\ISOs\ubuntu-22.04.3-live-server-amd64.iso"

# Skip Ubuntu VM deployment (Hyper-V only)
.\Install-ConfigureHyperV.ps1 -DeployUbuntuVM:$false

# Custom virtual switch name
.\Install-ConfigureHyperV.ps1 -VirtualSwitchName "Production-vSwitch"

# Skip restart prompt
.\Install-ConfigureHyperV.ps1 -SkipRestart
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-VMPath` | String | `C:\Hyper-V\VMs` | Default path for virtual machines |
| `-VHDPath` | String | `C:\Hyper-V\VHDs` | Default path for virtual hard disks |
| `-VirtualSwitchName` | String | `External-vSwitch` | Name for the virtual switch |
| `-CreateExternalSwitch` | Switch | `$true` | Create an external virtual switch |
| `-SkipRestart` | Switch | `$false` | Skip the restart prompt |
| `-ISOPath` | String | `C:\Hyper-V\ISOs` | Directory for ISO storage |
| `-DeployUbuntuVM` | Switch | `$true` | Deploy Ubuntu VM after configuration |
| `-UbuntuVMName` | String | `Ubuntu-Server` | Name for the Ubuntu VM |
| `-UbuntuVMMemory` | Long | `4GB` | Memory allocation (Dynamic: 1GB-8GB) |
| `-UbuntuVMDiskSize` | Long | `50GB` | Virtual disk size |
| `-UbuntuVMCPUCount` | Int | `2` | Number of virtual CPUs |
| `-UbuntuISOPath` | String | `""` | Path to existing ISO (optional) |

**Ubuntu VM Features:**
- Generation 2 VM (UEFI support)
- Dynamic memory (1GB minimum, 8GB maximum)
- Secure Boot disabled (Ubuntu compatibility)
- DVD drive with ISO attached
- Boot order set to DVD first
- Guest integration services enabled
- Automatic ISO download if not provided

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
