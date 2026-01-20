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

Automates the complete setup of Hyper-V on Windows Server 2022, including:

| Feature | Description |
|---------|-------------|
| Role Installation | Installs Hyper-V role with management tools |
| Storage Configuration | Creates default VM and VHD directories |
| Virtual Networking | Creates external virtual switch |
| Host Settings | Configures Enhanced Session Mode and NUMA spanning |
| Firewall Rules | Enables required firewall rules |

**Usage:**
```powershell
# Basic installation with defaults
.\Install-ConfigureHyperV.ps1

# Custom paths
.\Install-ConfigureHyperV.ps1 -VMPath "D:\VMs" -VHDPath "D:\VHDs"

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
