#!/bin/bash

#
# Verification Script for WSL2 Ansible Setup
#
# This script verifies that the Ansible environment is properly configured
# and all dependencies are installed.
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

section() {
    echo -e "\n${BLUE}==>${NC} $1"
}

# Error handling
trap 'echo -e "${RED}Error at line $LINENO${NC}"; exit 1' ERR

# Header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  WSL2 Ansible Setup Verification${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running in WSL
section "Environment Check"
if grep -qi microsoft /proc/version; then
    check_pass "Running in WSL environment"
else
    check_warn "Not running in WSL (this is okay if testing elsewhere)"
fi

# Check Ansible installation
section "Ansible Installation"
if command -v ansible &> /dev/null; then
    version=$(ansible --version | head -n 1)
    check_pass "Ansible installed: $version"
else
    check_fail "Ansible not found - run bootstrap.sh"
fi

# Check Python
section "Python Environment"
if command -v python3 &> /dev/null; then
    version=$(python3 --version)
    check_pass "Python installed: $version"
else
    check_fail "Python3 not found"
fi

# Check pip
if command -v pip3 &> /dev/null; then
    check_pass "pip3 installed"
else
    check_fail "pip3 not found"
fi

# Check ansible-lint
if command -v ansible-lint &> /dev/null; then
    check_pass "ansible-lint installed"
else
    check_warn "ansible-lint not found (optional but recommended)"
fi

# Check yamllint
if command -v yamllint &> /dev/null; then
    check_pass "yamllint installed"
else
    check_warn "yamllint not found (optional but recommended)"
fi

# Check directory structure
section "Directory Structure"
if [ -f "ansible.cfg" ]; then
    check_pass "ansible.cfg found"
else
    check_fail "ansible.cfg not found"
fi

if [ -f "inventory/hosts" ]; then
    check_pass "inventory/hosts found"
else
    check_fail "inventory/hosts not found"
fi

if [ -f "playbooks/main.yml" ]; then
    check_pass "playbooks/main.yml found"
else
    check_fail "playbooks/main.yml not found"
fi

if [ -f "vars/user_environment.yml" ]; then
    check_pass "vars/user_environment.yml found"
else
    check_fail "vars/user_environment.yml not found"
fi

# Check roles
section "Ansible Roles"
for role in common ssh-keys gpg-keys development kubernetes-tools docker; do
    if [ -d "roles/$role" ]; then
        check_pass "Role '$role' exists"

        # Check role structure
        if [ -f "roles/$role/tasks/main.yml" ]; then
            check_pass "  - tasks/main.yml exists"
        else
            check_fail "  - tasks/main.yml missing"
        fi
    else
        check_fail "Role '$role' not found"
    fi
done

# Check playbook syntax
section "Playbook Validation"
if command -v ansible-playbook &> /dev/null && [ -f "playbooks/main.yml" ]; then
    if ansible-playbook --syntax-check playbooks/main.yml &> /dev/null; then
        check_pass "Main playbook syntax is valid"
    else
        check_fail "Main playbook has syntax errors"
        echo "Run: ansible-playbook --syntax-check playbooks/main.yml"
    fi
fi

# Check inventory connectivity
section "Inventory Check"
if command -v ansible &> /dev/null && [ -f "inventory/hosts" ]; then
    if ansible local -m ping --become=false &> /dev/null; then
        check_pass "Localhost connectivity verified"
    else
        check_warn "Cannot connect to localhost (may require password for become)"
    fi
fi

# Check system resources
section "System Resources"
total_mem=$(free -h | awk '/^Mem:/ {print $2}')
cpu_count=$(nproc)
check_pass "Total Memory: $total_mem"
check_pass "CPU Cores: $cpu_count"

# Check optional tools
section "Optional Development Tools"
for tool in git curl wget vim docker node npm go rustc ruby terraform kubectl talosctl doppler gpg; do
    if command -v $tool &> /dev/null; then
        check_pass "$tool installed"
    else
        check_warn "$tool not installed (will be installed by playbook if enabled)"
    fi
done

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All critical checks passed!${NC}"
    echo -e "\nNext steps:"
    echo "  1. Review vars/user_environment.yml"
    echo "  2. Customize settings as needed"
    echo "  3. Run: ansible-playbook -K playbooks/main.yml"
    exit 0
else
    echo -e "\n${RED}✗ Some checks failed${NC}"
    echo -e "\nPlease resolve the failed checks before running playbooks."
    exit 1
fi
