<!-- DO NOT TOUCH THIS SECTION#1: START -->
<h1 align="center">
   <img src="./.github/assets/logo/wsl2-devenv-logo.svg" alt="WSL2 DevEnv Logo" width="200px" />
   <br>
      WSL2 DevEnv | Complete WSL2 Development Environment Automation
   <br>
      <img src="./.github/assets/pallet/pallet-0.png" alt="Project Banner" width="800px" /> <br>

   <div align="center">
      <p></p>
      <div align="center">
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/stargazers">
            <img src="https://img.shields.io/github/stars/MoshPitCodes/moshpitcodes.wsl2?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F" alt="GitHub Stars">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/">
            <img src="https://img.shields.io/github/repo-size/MoshPitCodes/moshpitcodes.wsl2?color=B16286&labelColor=282828&style=for-the-badge&logo=github&logoColor=B16286" alt="Repository Size">
         </a>
         <a href="https://www.microsoft.com/windows/wsl">
            <img src="https://img.shields.io/badge/WSL2-Windows_11-blue.svg?style=for-the-badge&labelColor=282828&logo=windows&logoColor=458588&color=458588" alt="WSL2 on Windows 11">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=Apache--2.0&colorA=282828&colorB=98971A&logo=apache&logoColor=98971A&" alt="Apache 2.0 License"/>
         </a>
      </div>
      <br>
      <div align="center">
         <a href="https://www.ansible.com/">
            <img src="https://img.shields.io/badge/Ansible-2.16+-EE0000.svg?style=for-the-badge&labelColor=282828&logo=ansible&logoColor=EE0000" alt="Ansible 2.16+">
         </a>
         <a href="https://docs.microsoft.com/en-us/powershell/">
            <img src="https://img.shields.io/badge/PowerShell-7.5+-5391FE.svg?style=for-the-badge&labelColor=282828&logo=powershell&logoColor=5391FE" alt="PowerShell 7.5+">
         </a>
         <a href="https://yaml.org/">
            <img src="https://img.shields.io/badge/YAML-Configuration-CB171E.svg?style=for-the-badge&labelColor=282828&logo=yaml&logoColor=CB171E" alt="YAML Configuration">
         </a>
      </div>
      <br>
      <div align="center">
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/actions/workflows/ansible-lint.yml">
            <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.wsl2/ansible-lint.yml?branch=main&style=for-the-badge&labelColor=282828&logo=ansible&logoColor=EE0000&label=Ansible%20Lint" alt="Ansible Lint">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/actions/workflows/powershell-lint.yml">
            <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.wsl2/powershell-lint.yml?branch=main&style=for-the-badge&labelColor=282828&logo=powershell&logoColor=5391FE&label=PowerShell%20Lint" alt="PowerShell Lint">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/actions/workflows/docs-validation.yml">
            <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.wsl2/docs-validation.yml?branch=main&style=for-the-badge&labelColor=282828&logo=markdown&logoColor=FFFFFF&label=Docs%20Validation" alt="Docs Validation">
         </a>
         <a href="https://github.com/MoshPitCodes/moshpitcodes.wsl2/actions/workflows/wsl2-test.yml">
            <img src="https://img.shields.io/github/actions/workflow/status/MoshPitCodes/moshpitcodes.wsl2/wsl2-test.yml?branch=main&style=for-the-badge&labelColor=282828&logo=windows&logoColor=458588&label=WSL2%20Tests" alt="WSL2 Integration Tests">
         </a>
      </div>
      <br>
   </div>
</h1>

<br/>
<!-- DO NOT TOUCH THIS SECTION#1: END -->

# 🗃️ Overview

Complete automation solution for installing and configuring WSL2 (Windows Subsystem for Linux) on Windows 11
with a comprehensive Ubuntu development environment managed by Ansible. This two-phase approach automates
everything from WSL2 installation to a fully configured development workspace with Docker, Kubernetes tools,
AI tools, and more.

> **Note:** Throughout this documentation, `~/development/moshpitcodes.wsl` is used as an example path.
> You can clone the repository to any location you prefer - just adjust the paths accordingly.

<br/>

## 📚 Project Structure

- [powershell/](powershell/) - PowerShell scripts for WSL2 installation and configuration on Windows
- [ansible/](ansible/) - Ansible playbooks and roles for Ubuntu environment configuration
- [ansible/roles/](ansible/roles/) - Modular roles for common, development, docker, kubernetes, and AI tools
- [ansible/vars/](ansible/vars/) - User configuration and environment variables
- [QUICK_START.md](QUICK_START.md) - Quick start guide for immediate setup
- [ansible/QUICK_REFERENCE.md](ansible/QUICK_REFERENCE.md) - Command reference guide

<br/>

## 📓 Project Components

| Component | Responsibility |
| --------------------------- | :---------------------------------------------------------------------------------- |
| **PowerShell Scripts** | Automated WSL2 installation, configuration, and .wslconfig management |
| **Ansible Bootstrap** | Automated Ansible installation and initial setup in WSL |
| **Common Role** | System packages, utilities, security updates, and base configuration |
| **SSH/GPG Keys** | Secure key management with automatic copying and permissions |
| **Development Tools** | Node.js, Go, Python, Rust, Ruby with version management |
| **Kubernetes Tools** | kubectl, terraform, talosctl for container orchestration |
| **Docker Setup** | Docker and Docker Compose with proper permissions |
| **AI Tools** | Claude Code, Gemini CLI, and Opencode for AI-assisted development |

<br/>

# 🚀 **Quick Start**

> [!CAUTION]
> Customizing system configurations, particularly those affecting operating systems, may lead to unforeseen
> effects and potentially disrupt your system's standard operations. Although I've personally tested these
> settings on my own hardware, they might not perform identically on your specific setup.
> **I cannot assume responsibility for any problems that might result from implementing this configuration.**

> [!WARNING]
> You **must** examine the configuration details and adjust them according to your specific requirements
> before proceeding. Review [vars/user_environment.yml](ansible/vars/user_environment.yml) carefully.

<br/>

## 1. **Prerequisites**

Before starting, ensure you have:

> [!NOTE]
> This was tested with the following parameters:
>
> - Windows 11 (22H2 or later recommended)
> - PowerShell 7.5 or higher
> - Administrator privileges on Windows
> - At least 8GB RAM and 4 CPU cores for optimal WSL2 performance
> - Internet connection for package downloads

**Verify your system:**

```powershell
# Check Windows version
winver

# Check PowerShell version
$PSVersionTable.PSVersion
```

<br/>

## 2. **Phase 1: Install WSL2 (Windows)**

From Windows PowerShell as Administrator:

```powershell
# Clone the repository
cd C:\Users\YourUsername\Projects  # Replace YourUsername
git clone <repository-url> moshpitcodes.wsl
cd moshpitcodes.wsl

# Step 1: Install WSL2 and Ubuntu
.\powershell\01-Install-WSL2.ps1

# System will reboot automatically. After reboot:
# - Launch "Ubuntu" from Start Menu
# - Create your username and password when prompted

# Step 2: Configure WSL2 resources
.\powershell\02-Configure-WSL2.ps1 -Memory "8GB" -Processors 4
```

<br/>

## 3. **Phase 2: Configure Ubuntu (WSL)**

> [!TIP]
> To ensure you understand what you're executing, it's advisable to review the code base or at minimum
> consult the documentation thoroughly prior to running the automation.

### Clone Repository in WSL

```bash
# Access WSL
wsl

# Clone repository
cd ~/development
git clone <repository-url> moshpitcodes.wsl
cd moshpitcodes.wsl/ansible
```

<br/>

### Initial Configuration

```bash
# First-time setup: Copy configuration from templates
cp ansible.cfg.template ansible.cfg
cp vars/user_environment.yml.template vars/user_environment.yml

# Edit configuration with your settings
nano vars/user_environment.yml
```

> **Important:** The files `ansible.cfg` and `vars/user_environment.yml` are gitignored to protect your
> personal settings. You must copy them from the `.template` files on first clone.

<br/>

### Bootstrap Ansible

```bash
# Install Ansible
./bootstrap.sh

# Run the main playbook to configure your system
ansible-playbook -K playbooks/main.yml

# Verify installation
./verify-setup.sh
```

<br/>

# 📝 **Configuration**

<details>
<summary>
<b>User Settings & Feature Toggles</b>
</summary>

```yaml
# User Configuration
target_user: moshpit
user_email: your.email@example.com
user_full_name: Your Name
user_shell: /bin/bash

# Feature Toggles
install_development_tools: true
install_docker: true
install_nodejs: true
install_python: true
install_golang: true
install_rust: false
install_ruby: false
install_kubernetes_tools: true
install_doppler: true
install_ai_tools: true
```

</details>

<details>
<summary>
<b>Version Specifications</b>
</summary>

```yaml
# Development Tools Versions
nodejs_version: "24.11.1"
golang_version: "1.25.4"
docker_compose_version: "2.40.3"

# Kubernetes Tools Versions
terraform_version: "1.13.5"
kubectl_version: "1.32.0"
talosctl_version: "1.9.2"
```

</details>

<details>
<summary>
<b>SSH & GPG Keys Configuration</b>
</summary>

```yaml
# SSH Keys
copy_ssh_keys: true
ssh_agent_autostart: true
ssh_agent_autoload_keys: true
# Source directory (use WSL mount path format: /mnt/drive/path)
# Example: /mnt/f/Backups/.ssh or /mnt/c/Users/YourName/backup/.ssh
ssh_keys_source: "/mnt/f/path/to/.ssh"

# GPG Keys
copy_gpg_keys: true
gpg_keys_source: "/mnt/f/path/to/.gnupg"
gpg_enable_ssh_support: false
```

**Security Notes:**

- Private keys automatically set to mode 600 (read/write for owner only)
- Public keys set to mode 644 (readable by all, writable by owner)
- .ssh directory set to mode 700 (accessible only by owner)
- Ensure your backup drive is mounted before running the playbook

For detailed SSH and GPG setup, see:

- [SSH Agent Guide](ansible/SSH_AGENT_GUIDE.md)
- [GPG Keys Guide](ansible/GPG_KEYS_GUIDE.md)

</details>

<br/>

# 📐 Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                    Windows 11 Host System                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              PowerShell Automation Layer                  │  │
│  │  • 01-Install-WSL2.ps1 (WSL2 Installation)               │  │
│  │  • 02-Configure-WSL2.ps1 (.wslconfig Management)         │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    WSL2 Instance                          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │           Ubuntu Development Environment            │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │         Ansible Configuration Layer          │  │  │  │
│  │  │  │  • bootstrap.sh → Ansible Installation       │  │  │  │
│  │  │  │  • playbooks/main.yml → Main Orchestration   │  │  │  │
│  │  │  └───────────────────────────────────────────────┘  │  │  │
│  │  │                      ↓                               │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │              Ansible Roles                    │  │  │  │
│  │  │  │  • common (base system)                       │  │  │  │
│  │  │  │  • ssh-keys (key management)                  │  │  │  │
│  │  │  │  • gpg-keys (GPG setup)                       │  │  │  │
│  │  │  │  • development (languages & tools)            │  │  │  │
│  │  │  │  • docker (containerization)                  │  │  │  │
│  │  │  │  • kubernetes-tools (orchestration)           │  │  │  │
│  │  │  │  • ai-tools (AI assistants)                   │  │  │  │
│  │  │  └───────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

<br/>

# 📋 **Detailed Usage**

## Available Ansible Tags

Run specific components using tags:

```bash
# Run specific roles
ansible-playbook -K --tags "docker" playbooks/main.yml
ansible-playbook -K --tags "ssh,gpg" playbooks/main.yml
ansible-playbook -K --tags "ai-tools" playbooks/main.yml

# Available tags:
# - always: Runs every time (pre/post tasks)
# - common: Common system configuration and utilities
# - ssh: SSH key copying and configuration
# - gpg: GPG key copying and configuration
# - development: Development tools and programming languages
# - kubernetes: Kubernetes tools (kubectl, terraform, talosctl)
# - docker: Docker installation and configuration
# - ai-tools: AI/ML tools and frameworks
# - cleanup: Cleanup tasks (apt autoclean/autoremove)

# List all available tags
ansible-playbook --list-tags playbooks/main.yml
```

## PowerShell Scripts

### 01-Install-WSL2.ps1

```powershell
# Basic installation
.\powershell\01-Install-WSL2.ps1

# Advanced options
.\powershell\01-Install-WSL2.ps1 -Distribution Ubuntu-22.04
.\powershell\01-Install-WSL2.ps1 -SkipReboot
.\powershell\01-Install-WSL2.ps1 -Phase2  # Continue after manual reboot
```

### 02-Configure-WSL2.ps1

```powershell
# Default configuration (4GB RAM, 2 CPUs)
.\powershell\02-Configure-WSL2.ps1

# Custom resource allocation
.\powershell\02-Configure-WSL2.ps1 -Memory "8GB" -Processors 4 -Swap "2GB"
.\powershell\02-Configure-WSL2.ps1 -Force  # Overwrite without prompting

# Apply changes
wsl --shutdown
Start-Sleep -Seconds 8
wsl
```

## Verification

```bash
# Verify installation
cd ~/development/moshpitcodes.wsl/ansible
./verify-setup.sh

# What it checks:
# - Ansible installation and version
# - Installed roles and their configurations
# - Command availability (docker, kubectl, terraform, etc.)
# - Service status (Docker daemon)
# - SSH keys and agent status
# - GPG keys status
```

<br/>

# 🛠️ **Troubleshooting**

<details>
<summary>
<b>WSL Installation Issues</b>
</summary>

#### "WSL 2 requires an update to its kernel component"

Download and install: <https://aka.ms/wsl2kernel>

```powershell
wsl --set-default-version 2
```

#### "Please enable Virtual Machine Platform"

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Restart-Computer
```

**Check WSL status:**

```powershell
wsl --list --verbose
wsl --status
wsl --version
```

</details>

<details>
<summary>
<b>Ansible Issues</b>
</summary>

#### "ansible: command not found"

```bash
source ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
ansible --version
```

**Playbook fails:**

```bash
# Run with verbose output
ansible-playbook -K -vvv playbooks/main.yml

# Check syntax
ansible-playbook --syntax-check playbooks/main.yml

# Dry run
ansible-playbook --check playbooks/main.yml
```

</details>

<details>
<summary>
<b>Docker Issues</b>
</summary>

**Docker daemon not running:**

```bash
sudo service docker start
sudo service docker status
```

**Permission denied:**

```bash
groups
newgrp docker
docker run hello-world
```

**Enable systemd (Windows 11):**

```bash
sudo nano /etc/wsl.conf
```

Add:

```ini
[boot]
systemd=true
```

Then:

```powershell
wsl --shutdown
wsl
```

</details>

<br/>

# 👥 Credits

This project builds upon excellent work from the community:

- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/): Official Microsoft WSL documentation
- [Ansible Documentation](https://docs.ansible.com/): Comprehensive Ansible guides
- [Docker on WSL](https://docs.docker.com/desktop/wsl/): Docker WSL integration guide
- [Jeff Geerling's Ansible Work](https://www.jeffgeerling.com/): Ansible best practices and examples

<br/>

<!-- DO NOT TOUCH THIS SECTION#2: START -->
<!-- # ✨ Stars History -->

<br/>

<p align="center"><img src="https://api.star-history.com/svg?repos=MoshPitCodes/moshpitcodes.wsl2&type=Timeline&theme=dark" alt="Star History Chart" /></p>

<br/>

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" alt="Catppuccin Footer" /></p>

<!-- end of page, send back to the top -->

<div align="right">
  <a href="#readme">Back to the Top</a>
</div>
<!-- DO NOT TOUCH THIS SECTION#2: END -->
