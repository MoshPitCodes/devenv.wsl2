#!/bin/bash

#
# Ansible Bootstrap Script for WSL2 Ubuntu
#
# This script installs Ansible and all required dependencies
# in a WSL2 Ubuntu environment.
#

set -e  # Exit on any error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

# Check if running in WSL
check_wsl() {
    if ! grep -qi microsoft /proc/version; then
        log_warning "This script is designed for WSL2 Ubuntu"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    else
        log_success "Running in WSL environment"
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should NOT be run as root"
        log_info "Run as regular user. Sudo will be used when needed."
        exit 1
    fi
}

# Update package lists
update_packages() {
    log_step "Updating package lists..."
    sudo apt update
    log_success "Package lists updated"
}

# Upgrade existing packages
upgrade_packages() {
    log_step "Upgrading existing packages..."
    log_warning "This may take a while..."
    sudo apt upgrade -y
    log_success "Packages upgraded"
}

# Install prerequisites
install_prerequisites() {
    log_step "Installing prerequisites..."

    local packages=(
        software-properties-common
        python3
        python3-pip
        python3-dev
        git
        curl
        wget
        build-essential
        libffi-dev
        libssl-dev
        libyaml-dev
        python3-apt
    )

    log_info "Installing: ${packages[*]}"
    sudo apt install -y "${packages[@]}"

    log_success "Prerequisites installed"
}

# Add Ansible PPA
add_ansible_ppa() {
    log_step "Adding Ansible PPA..."

    # Check if PPA is already added
    if grep -q "ansible/ansible" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        log_warning "Ansible PPA already added, skipping..."
    else
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        log_success "Ansible PPA added"
    fi
}

# Install Ansible
install_ansible() {
    log_step "Installing Ansible..."

    # Check if Ansible is already installed
    if command -v ansible &> /dev/null; then
        local current_version
        current_version=$(ansible --version | head -n 1)
        log_warning "Ansible already installed: $current_version"
        read -p "Reinstall/Upgrade? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping Ansible installation"
            return 0
        fi
    fi

    sudo apt install -y ansible
    log_success "Ansible installed"
}

# Install Python dependencies
install_python_deps() {
    log_step "Installing Python dependencies..."

    # Try to install packages from apt first (preferred method for Ubuntu 24.04+)
    local apt_packages=(
        python3-jmespath
        python3-netaddr
        python3-passlib
    )

    log_info "Installing Python packages from apt: ${apt_packages[*]}"
    sudo apt install -y "${apt_packages[@]}" 2>/dev/null || log_warning "Some apt packages not available"

    # For packages not available via apt, use pipx (PEP 668 compliant)
    # pipx installs packages in isolated environments, avoiding system package conflicts
    local pipx_packages=(
        ansible-lint
        yamllint
    )

    # Check if pipx is available, install if not
    if ! command -v pipx &> /dev/null; then
        log_info "Installing pipx for isolated package management..."
        sudo apt install -y pipx 2>/dev/null || {
            log_warning "pipx not available via apt, falling back to pip"
            pip3 install --user --break-system-packages pipx
        }
        # Ensure pipx bin directory is in PATH
        pipx ensurepath 2>/dev/null || true
    fi

    log_info "Installing Python packages via pipx: ${pipx_packages[*]}"

    for pkg in "${pipx_packages[@]}"; do
        if command -v pipx &> /dev/null; then
            # Use pipx for isolated installation (preferred)
            pipx install "$pkg" 2>/dev/null || pipx upgrade "$pkg" 2>/dev/null || {
                log_warning "pipx install failed for $pkg, trying pip fallback"
                pip3 install --user --break-system-packages --upgrade "$pkg"
            }
        else
            # Fallback to pip with --break-system-packages (Ubuntu 24.04+)
            pip3 install --user --break-system-packages --upgrade "$pkg"
        fi
    done

    log_success "Python dependencies installed"
}

# Add pip bin to PATH if needed
configure_path() {
    log_step "Configuring PATH..."

    local pip_bin="$HOME/.local/bin"

    if [[ ":$PATH:" != *":$pip_bin:"* ]]; then
        log_info "Adding $pip_bin to PATH in ~/.bashrc"

        cat >> ~/.bashrc << 'EOF'

# Ansible bootstrap: Add pip user bin to PATH
export PATH="$HOME/.local/bin:$PATH"
EOF

        log_success "PATH configured (restart shell or source ~/.bashrc)"
    else
        log_info "PATH already configured"
    fi
}

# Verify installation
verify_installation() {
    log_step "Verifying installation..."

    # Check Ansible
    if ! command -v ansible &> /dev/null; then
        log_error "Ansible not found in PATH"
        return 1
    fi

    # Get versions
    local ansible_version
    ansible_version=$(ansible --version | head -n 1)
    log_success "Ansible: $ansible_version"

    # Check Python version
    local python_version
    python_version=$(python3 --version)
    log_success "Python: $python_version"

    # Check ansible-lint
    if command -v ansible-lint &> /dev/null; then
        local lint_version
        lint_version=$(ansible-lint --version | head -n 1)
        log_success "ansible-lint: $lint_version"
    else
        log_warning "ansible-lint not in PATH (may need to source ~/.bashrc)"
    fi

    # Check yamllint
    if command -v yamllint &> /dev/null; then
        local yaml_version
        yaml_version=$(yamllint --version)
        log_success "yamllint: $yaml_version"
    else
        log_warning "yamllint not in PATH (may need to source ~/.bashrc)"
    fi

    log_success "Verification complete"
}

# Create Ansible directories
setup_directories() {
    log_step "Setting up Ansible directories..."

    local dirs=(
        ~/.ansible
        ~/.ansible/tmp
        ~/.ansible/roles
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created: $dir"
        fi
    done

    log_success "Directories ready"
}

# Display completion message
show_completion() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Ansible Bootstrap Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    log_info "Ansible is now ready to use!"
    echo ""

    echo -e "${CYAN}Quick Start:${NC}"
    echo "  1. Reload shell or source ~/.bashrc:"
    echo -e "     ${YELLOW}source ~/.bashrc${NC}"
    echo ""
    echo "  2. Verify installation:"
    echo -e "     ${YELLOW}ansible --version${NC}"
    echo ""
    echo "  3. Run playbooks from the repository ansible directory:"
    echo -e "     ${YELLOW}ansible-playbook -K playbooks/main.yml${NC}"
    echo -e "     ${YELLOW}ansible-playbook -K playbooks/ssh-keys.yml${NC}"
    echo ""

    echo -e "${CYAN}Useful Commands:${NC}"
    echo "  Check syntax:        ansible-playbook --syntax-check <playbook.yml>"
    echo "  List tasks:          ansible-playbook --list-tasks <playbook.yml>"
    echo "  Dry run:             ansible-playbook --check <playbook.yml>"
    echo "  Lint playbook:       ansible-lint <playbook.yml>"
    echo "  Lint YAML:           yamllint <file.yml>"
    echo ""
}

# Main execution
main() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Ansible Bootstrap for WSL2${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    # Perform checks
    check_root
    check_wsl

    # Installation steps
    update_packages
    upgrade_packages
    install_prerequisites
    add_ansible_ppa
    install_ansible
    install_python_deps
    configure_path
    setup_directories
    verify_installation

    # Show completion message
    show_completion
}

# Error handling
trap 'log_error "Script failed at line $LINENO"' ERR

# Run main function
main "$@"
