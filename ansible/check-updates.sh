#!/bin/bash

#
# Update Notification Script for WSL2 DevEnv
#
# This script checks for updates to the repository and notifies
# the user if new changes are available.
#

set -e
set -u
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE_CHECK_FILE="$HOME/.ansible-last-update-check"
CHECK_INTERVAL_DAYS=7
REMOTE_NAME="origin"
REMOTE_BRANCH="main"

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

# Check if we should run the update check
should_check_updates() {
    # If force check, always return true
    if [[ "${FORCE_CHECK:-false}" == "true" ]]; then
        return 0
    fi

    # If no check file exists, check now
    if [[ ! -f "$UPDATE_CHECK_FILE" ]]; then
        return 0
    fi

    # Check if enough time has passed
    local last_check=$(cat "$UPDATE_CHECK_FILE")
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_check))
    local interval_seconds=$((CHECK_INTERVAL_DAYS * 86400))

    if [[ $time_diff -gt $interval_seconds ]]; then
        return 0
    fi

    return 1
}

# Update the last check timestamp
update_check_timestamp() {
    date +%s > "$UPDATE_CHECK_FILE"
}

# Check if we're in a git repository
check_git_repo() {
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        log_error "Not a git repository: $REPO_DIR"
        exit 1
    fi

    cd "$REPO_DIR"
}

# Fetch latest changes
fetch_updates() {
    log_info "Fetching latest changes from remote..."

    if ! git fetch "$REMOTE_NAME" "$REMOTE_BRANCH" --quiet 2>/dev/null; then
        log_warning "Failed to fetch updates (network issue or no remote configured)"
        return 1
    fi

    log_success "Fetched latest changes"
    return 0
}

# Check for updates
check_for_updates() {
    local current_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse "$REMOTE_NAME/$REMOTE_BRANCH" 2>/dev/null || echo "")

    if [[ -z "$remote_commit" ]]; then
        log_warning "Could not determine remote commit"
        return 1
    fi

    if [[ "$current_commit" == "$remote_commit" ]]; then
        log_success "Your repository is up to date!"
        return 1
    fi

    # Count commits behind
    local commits_behind=$(git rev-list --count HEAD.."$REMOTE_NAME/$REMOTE_BRANCH" 2>/dev/null || echo "0")

    if [[ $commits_behind -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}  Updates Available!${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo ""
        log_warning "You are $commits_behind commit(s) behind $REMOTE_NAME/$REMOTE_BRANCH"
        echo ""

        # Show recent commits
        log_info "Recent changes:"
        echo ""
        git log --oneline --decorate --color=always HEAD.."$REMOTE_NAME/$REMOTE_BRANCH" | head -10

        echo ""
        echo -e "${CYAN}To update:${NC}"
        echo "  cd $REPO_DIR"
        echo "  git pull $REMOTE_NAME $REMOTE_BRANCH"
        echo ""
        echo -e "${YELLOW}Note: Review changes before updating to avoid conflicts${NC}"
        echo ""

        return 0
    fi

    return 1
}

# Check for uncommitted changes
check_local_changes() {
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_warning "You have uncommitted local changes"
        echo ""
        log_info "Modified files:"
        git status --short
        echo ""
        log_info "Consider committing or stashing changes before updating"
        return 0
    fi

    return 1
}

# Display current version info
show_version_info() {
    log_info "Current version information:"
    echo ""
    echo "  Repository: $REPO_DIR"
    echo "  Branch: $(git branch --show-current)"
    echo "  Commit: $(git rev-parse --short HEAD)"
    echo "  Date: $(git log -1 --format=%cd --date=short)"
    echo "  Message: $(git log -1 --format=%s)"
    echo ""
}

# Main execution
main() {
    # Check if we should run
    if ! should_check_updates; then
        local last_check=$(cat "$UPDATE_CHECK_FILE")
        local next_check=$((last_check + CHECK_INTERVAL_DAYS * 86400))
        local next_check_date=$(date -d "@$next_check" "+%Y-%m-%d %H:%M:%S")

        if [[ "${VERBOSE:-false}" == "true" ]]; then
            log_info "Update check not needed yet"
            log_info "Next check scheduled for: $next_check_date"
        fi
        exit 0
    fi

    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  WSL2 DevEnv Update Check${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    # Run checks
    check_git_repo
    show_version_info
    check_local_changes

    if fetch_updates; then
        if check_for_updates; then
            # Updates available
            update_check_timestamp
            exit 2  # Exit code 2 indicates updates available
        else
            # No updates
            update_check_timestamp
            exit 0
        fi
    else
        # Fetch failed
        log_warning "Could not check for updates"
        exit 1
    fi
}

# Parse arguments
FORCE_CHECK=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_CHECK=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --interval)
            CHECK_INTERVAL_DAYS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force           Force update check regardless of interval"
            echo "  --verbose, -v     Show verbose output"
            echo "  --interval DAYS   Set check interval in days (default: 7)"
            echo "  --help            Show this help message"
            echo ""
            echo "Exit codes:"
            echo "  0 - No updates available"
            echo "  1 - Error occurred"
            echo "  2 - Updates available"
            echo ""
            echo "Examples:"
            echo "  $0                    # Check for updates (respects interval)"
            echo "  $0 --force            # Force immediate check"
            echo "  $0 --interval 3       # Set 3-day check interval"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Error handling
trap 'log_error "Update check failed at line $LINENO"' ERR

# Run main function
main "$@"
