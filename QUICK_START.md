# Quick Start Guide

> **Note:** This guide uses `~/development/moshpitcodes.wsl` as an example path. You can clone the repository to any location you prefer - just adjust the paths accordingly throughout the guide.

## Initial Setup (Windows PowerShell as Administrator)

```powershell
# 1. Install WSL2 and Ubuntu
.\powershell\01-Install-WSL2.ps1

# After reboot and Ubuntu setup (creating username/password):

# 2. Configure WSL2 resources
.\powershell\02-Configure-WSL2.ps1 -Memory "8GB" -Processors 4

# 3. Clone/Access the repository in WSL, then bootstrap Ansible
wsl
cd ~/development  # or your preferred location
git clone <your-repo-url> moshpitcodes.wsl
cd moshpitcodes.wsl/ansible

# First-time setup: Copy configuration from templates
cp ansible.cfg.template ansible.cfg
cp vars/user_environment.yml.template vars/user_environment.yml

# Edit your settings
nano vars/user_environment.yml

# Bootstrap Ansible
./bootstrap.sh
```

## Customization (Inside WSL)

```bash
# Edit configuration
cd ~/development/moshpitcodes.wsl/ansible  # or your repository location
nano vars/user_environment.yml

# Apply changes
ansible-playbook -K playbooks/main.yml
```

> **First-Time Setup:** If you just cloned the repo, remember to copy `ansible.cfg.template` and `vars/user_environment.yml.template` to their non-template names first (see Initial Setup above).

For detailed customization options, see [README.md](README.md#customization).

## Common Commands

### Windows (PowerShell)

```powershell
# WSL Management
wsl                          # Start default WSL
wsl -d Ubuntu                # Start specific distribution
wsl --list --verbose         # List distributions
wsl --shutdown               # Shutdown all WSL instances
wsl --status                 # Check WSL status

# Configuration
.\powershell\02-Configure-WSL2.ps1 -Memory "8GB" -Processors 4
```

### WSL Ubuntu

```bash
# Ansible
cd ~/development/moshpitcodes.wsl/ansible  # or your repository location
ansible-playbook -K playbooks/main.yml                    # Run main playbook
ansible-playbook --check playbooks/main.yml               # Dry run
ansible-playbook -K --tags "ssh" playbooks/main.yml       # Copy SSH keys only
ansible-playbook -K --tags "docker" playbooks/main.yml    # Run specific role
ansible-playbook --list-tasks playbooks/main.yml          # List tasks
ansible-playbook --syntax-check playbooks/main.yml        # Check syntax

# Docker (if installed)
sudo service docker start    # Start Docker
docker ps                    # List containers
docker images                # List images

# System
sudo apt update && sudo apt upgrade -y    # Update packages
free -h                                   # Check memory
nproc                                     # Check CPU count
htop                                      # System monitor
```

## Troubleshooting

```powershell
# Windows - Reset WSL
wsl --shutdown
wsl --unregister Ubuntu      # WARNING: Deletes all data
wsl --install -d Ubuntu      # Reinstall
```

```bash
# WSL - Fix Ansible not found
source ~/.bashrc
ansible --version

# WSL - Fix Docker permission
newgrp docker

# WSL - Start Docker
sudo service docker start
```

## Key Files & Documentation

- **Windows WSL Config**: `%USERPROFILE%\.wslconfig`
- **Ansible Variables**: [ansible/vars/user_environment.yml](ansible/vars/user_environment.yml)
- **SSH Setup Guide**: [ansible/SSH_AGENT_GUIDE.md](ansible/SSH_AGENT_GUIDE.md)
- **GPG Keys Guide**: [ansible/GPG_KEYS_GUIDE.md](ansible/GPG_KEYS_GUIDE.md)
- **Quick Reference**: [ansible/QUICK_REFERENCE.md](ansible/QUICK_REFERENCE.md)

## Next Steps

1. ✅ Install WSL2
2. ✅ Configure resources
3. ✅ Bootstrap Ansible
4. 📝 Customize `vars/user_environment.yml`
5. 🚀 Run playbook
6. 🔄 Iterate and refine

For detailed documentation, see [README.md](README.md)
