# Quick Reference - Ansible WSL2 Setup

> **Note:** This guide uses `~/development/moshpitcodes.wsl` as an example path. Adjust to your repository location.

## Running Playbooks

```bash
cd ~/development/moshpitcodes.wsl/ansible

# Run everything
ansible-playbook -K playbooks/main.yml

# Dry run (check what would change)
ansible-playbook --check playbooks/main.yml

# Run specific roles only
ansible-playbook -K --tags "ssh" playbooks/main.yml          # SSH keys only
ansible-playbook -K --tags "gpg" playbooks/main.yml          # GPG keys only
ansible-playbook -K --tags "kubernetes" playbooks/main.yml   # Kubernetes tools only
ansible-playbook -K --tags "docker" playbooks/main.yml       # Docker only
ansible-playbook -K --tags "ai-tools" playbooks/main.yml     # AI/ML tools only

# Run multiple tags
ansible-playbook -K --tags "ssh,gpg" playbooks/main.yml
```

## Configuration

Edit: `~/development/moshpitcodes.wsl/ansible/vars/user_environment.yml`

### Key Settings

```yaml
# SSH Keys
copy_ssh_keys: true
ssh_agent_autostart: true
ssh_agent_autoload_keys: true
ssh_keys_source: "/mnt/f/path/to/.ssh"

# GPG Keys
copy_gpg_keys: true
gpg_keys_source: "/mnt/f/path/to/.gnupg"
gpg_enable_ssh_support: false

# Development Tools
install_development_tools: true
install_nodejs: true
install_golang: true
install_rust: true
install_docker: true
install_doppler: true
install_nix: false
nodejs_version: "24.11.1"
golang_version: "1.25.4"
docker_compose_version: "2.40.3"

# Kubernetes Tools
install_kubernetes_tools: true
terraform_version: "1.13.5"
kubectl_version: "1.32.0"
talosctl_version: "1.9.2"
```

## Quick Commands

### SSH Keys

```bash
# List loaded SSH keys
ssh-add -l

# Load SSH keys manually
~/.ssh/load-keys.sh

# Test SSH connection
ssh -T git@github.com
```

### GPG Keys

```bash
# List GPG keys
gpg --list-secret-keys

# Sign a Git commit
git commit -S -m "Signed commit"

# Verify GPG setup
echo "test" | gpg --clearsign
```

### Kubernetes Tools

```bash
# Check versions
kubectl version --client
talosctl version --client
terraform version

# Use kubectl alias
k get pods

# Get kubectl completions
kubectl get <TAB><TAB>
```

### Doppler

```bash
# Login to Doppler
doppler login

# Setup project
doppler setup
```

### Nix Package Manager

```bash
# Search for packages
nix search nixpkgs <package-name>

# Install a package temporarily
nix shell nixpkgs#<package-name>

# Install a package to user profile
nix profile install nixpkgs#<package-name>

# List installed packages
nix profile list

# Update all packages
nix profile upgrade '.*'

# Check Nix version
nix --version
```

### Docker

```bash
# Start Docker
sudo service docker start

# Run without sudo (after playbook)
docker ps
docker images
```

## Verification

```bash
# Run verification script
cd ~/development/moshpitcodes.wsl/ansible
./verify-setup.sh

# Check Ansible syntax
ansible-playbook --syntax-check playbooks/main.yml

# List available tasks
ansible-playbook --list-tasks playbooks/main.yml

# List available tags
ansible-playbook --list-tags playbooks/main.yml
```

## After Running Playbook

```bash
# Reload shell to apply changes
source ~/.bashrc

# Verify SSH agent
ssh-add -l

# Verify GPG
gpg --list-secret-keys

# Verify tools
kubectl version --client
terraform version
doppler --version
nix --version
```

## Available Tags

Tags correspond to roles in the main playbook:

- `always` - Runs every time (pre/post tasks)
- `common` - Common system configuration and utilities
- `ssh` - SSH key copying and agent setup
- `gpg` - GPG key copying and configuration
- `development` - Development tools and programming languages
- `kubernetes` - Kubernetes tools (kubectl, terraform, talosctl)
- `docker` - Docker and Docker Compose
- `ai-tools` - AI/ML tools and frameworks
- `cleanup` - Cleanup tasks (apt autoclean/autoremove)

**Granular Tags:** Additional tags are available for specific components: `python`, `nodejs`, `golang`, `rust`, `ruby`, `doppler`, `nix`, `git`, `shell`, `packages`, `security`, `performance`, `kubectl`, `terraform`, `talosctl`, `claude`, `gemini`, `opencode`. Use `ansible-playbook --list-tags playbooks/main.yml` to see all available tags.

## Troubleshooting

```bash
# Ansible connection issues
ansible local -m ping --become=false

# Check inventory
ansible-inventory --list

# Verbose output
ansible-playbook -K -vvv playbooks/main.yml

# Check logs
journalctl -xe
```

## Documentation

- **SSH Agent Guide**: [SSH_AGENT_GUIDE.md](SSH_AGENT_GUIDE.md)
- **GPG Keys Guide**: [GPG_KEYS_GUIDE.md](GPG_KEYS_GUIDE.md)
- **Quick Start**: [../QUICK_START.md](../QUICK_START.md)
- **Main README**: [../README.md](../README.md)
