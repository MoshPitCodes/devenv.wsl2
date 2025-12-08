#!/bin/bash

#
# Ansible Fact Cache Cleanup Script
#
# This script cleans up old Ansible fact cache files to prevent
# stale data and disk space issues.
#
# Usage:
#   ./cleanup-fact-cache.sh [--age DAYS] [--dry-run]
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default settings
CACHE_DIR="${HOME}/.ansible/facts_cache"
MAX_AGE_DAYS=30
DRY_RUN=false

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --age)
            MAX_AGE_DAYS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --age DAYS      Delete cache files older than DAYS (default: 30)"
            echo "  --dry-run       Show what would be deleted without deleting"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --age 7              # Delete files older than 7 days"
            echo "  $0 --dry-run            # Preview what would be deleted"
            echo "  $0 --age 14 --dry-run   # Preview deletion of files older than 14 days"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            log_info "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Error handling
trap 'log_error "Script failed at line $LINENO"' ERR

# Main execution
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Ansible Fact Cache Cleanup${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Check if cache directory exists
    if [[ ! -d "$CACHE_DIR" ]]; then
        log_warning "Cache directory does not exist: $CACHE_DIR"
        log_info "Nothing to clean up"
        exit 0
    fi

    log_info "Cache directory: $CACHE_DIR"
    log_info "Max age: $MAX_AGE_DAYS days"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No files will be deleted"
    fi

    # Get cache statistics
    local total_files
    total_files=$(find "$CACHE_DIR" -type f 2>/dev/null | wc -l)

    local total_size
    total_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)

    log_info "Total cache files: $total_files"
    log_info "Total cache size: $total_size"

    # Find old files
    local old_files
    old_files=$(find "$CACHE_DIR" -type f -mtime +"$MAX_AGE_DAYS" 2>/dev/null | wc -l)

    if [[ $old_files -eq 0 ]]; then
        log_success "No files older than $MAX_AGE_DAYS days found"
        exit 0
    fi

    log_warning "Found $old_files files older than $MAX_AGE_DAYS days"

    # List files to be deleted
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        log_info "Files that would be deleted:"
        find "$CACHE_DIR" -type f -mtime +"$MAX_AGE_DAYS" -exec ls -lh {} \; | \
            awk '{print "  " $9 " (" $5 ", modified: " $6 " " $7 " " $8 ")"}'
    else
        # Delete old files
        echo ""
        log_info "Deleting old cache files..."

        local deleted_count=0
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
                ((deleted_count++))
            fi
        done < <(find "$CACHE_DIR" -type f -mtime +"$MAX_AGE_DAYS")

        log_success "Deleted $deleted_count files"

        # Show new statistics
        local remaining_files
        remaining_files=$(find "$CACHE_DIR" -type f 2>/dev/null | wc -l)

        local remaining_size
        remaining_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)

        log_info "Remaining files: $remaining_files"
        log_info "Remaining size: $remaining_size"
    fi

    # Clean up empty directories
    if [[ "$DRY_RUN" == "false" ]]; then
        find "$CACHE_DIR" -type d -empty -delete 2>/dev/null || true
    fi

    echo ""
    log_success "Cleanup complete!"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Run without --dry-run to actually delete files"
    else
        log_info "Fact gathering will regenerate cache on next playbook run"
    fi

    echo ""
}

# Run main function
main "$@"
