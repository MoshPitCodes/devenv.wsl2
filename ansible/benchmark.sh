#!/bin/bash

#
# Ansible Playbook Performance Benchmarking Script
#
# This script runs the main playbook and captures performance metrics
# to help identify bottlenecks and track improvements over time.
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
BENCHMARK_DIR="$HOME/.ansible-benchmarks"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BENCHMARK_FILE="$BENCHMARK_DIR/benchmark-$TIMESTAMP.json"
RESULTS_FILE="$BENCHMARK_DIR/results-$TIMESTAMP.txt"

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

# Create benchmark directory
setup_benchmark_dir() {
    if [[ ! -d "$BENCHMARK_DIR" ]]; then
        mkdir -p "$BENCHMARK_DIR"
        log_info "Created benchmark directory: $BENCHMARK_DIR"
    fi
}

# Display header
show_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Ansible Playbook Benchmark${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    log_info "Timestamp: $(date)"
    log_info "Benchmark file: $BENCHMARK_FILE"
    log_info "Results file: $RESULTS_FILE"
    echo ""
}

# Capture system info
capture_system_info() {
    log_step "Capturing system information..."

    cat > "$RESULTS_FILE" <<EOF
==================================================
Ansible Playbook Performance Benchmark
==================================================
Timestamp: $(date -Iseconds)
Hostname: $(hostname)

System Information:
-------------------
OS: $(lsb_release -ds 2>/dev/null || echo "Unknown")
Kernel: $(uname -r)
CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
CPU Cores: $(nproc)
Memory: $(free -h | awk '/^Mem:/ {print $2}')
Disk Space: $(df -h / | awk 'NR==2 {print $4}')

Ansible Version:
---------------
$(ansible --version)

==================================================

EOF

    log_success "System information captured"
}

# Run playbook with profiling
run_benchmark() {
    log_step "Running playbook with performance profiling..."

    local playbook="${1:-playbooks/main.yml}"
    local check_mode="${2:-false}"

    log_info "Playbook: $playbook"
    log_info "Check mode: $check_mode"

    # Enable Ansible profiling and timing
    export ANSIBLE_CALLBACKS_ENABLED="profile_tasks,timer"
    export ANSIBLE_CALLBACK_RESULT_FORMAT="json"

    # Run playbook and capture timing
    local start_time=$(date +%s)

    if [[ "$check_mode" == "true" ]]; then
        log_warning "Running in check mode (dry run)"
        ANSIBLE_CALLBACK_RESULT_FORMAT=json ansible-playbook \
            --check \
            "$playbook" 2>&1 | tee -a "$RESULTS_FILE"
    else
        log_warning "Running playbook (this will make changes!)"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Benchmark cancelled"
            exit 0
        fi

        ANSIBLE_CALLBACK_RESULT_FORMAT=json ansible-playbook \
            "$playbook" 2>&1 | tee -a "$RESULTS_FILE"
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "" >> "$RESULTS_FILE"
    echo "==================================================" >> "$RESULTS_FILE"
    echo "Benchmark Results" >> "$RESULTS_FILE"
    echo "==================================================" >> "$RESULTS_FILE"
    echo "Total Duration: ${duration}s ($(date -u -d @${duration} +%T))" >> "$RESULTS_FILE"
    echo "Start Time: $(date -d @${start_time})" >> "$RESULTS_FILE"
    echo "End Time: $(date -d @${end_time})" >> "$RESULTS_FILE"
    echo "==================================================" >> "$RESULTS_FILE"

    log_success "Playbook execution completed in ${duration}s"
}

# Analyze results
analyze_results() {
    log_step "Analyzing results..."

    # Extract slow tasks (if profile_tasks was enabled)
    if grep -q "Playbook run took" "$RESULTS_FILE"; then
        echo "" >> "$RESULTS_FILE"
        echo "==================================================" >> "$RESULTS_FILE"
        echo "Performance Analysis" >> "$RESULTS_FILE"
        echo "==================================================" >> "$RESULTS_FILE"

        # Extract timing information
        grep -A 50 "Playbook run took" "$RESULTS_FILE" >> "$RESULTS_FILE" || true

        log_success "Performance analysis added to results"
    else
        log_warning "Profile data not found. Enable profile_tasks callback for detailed analysis."
    fi
}

# Compare with previous runs
compare_benchmarks() {
    log_step "Comparing with previous benchmarks..."

    local previous_runs=$(find "$BENCHMARK_DIR" -name "results-*.txt" -type f | wc -l)

    if [[ $previous_runs -gt 1 ]]; then
        log_info "Found $previous_runs previous benchmark runs"

        # Get the most recent previous run
        local prev_result=$(find "$BENCHMARK_DIR" -name "results-*.txt" -type f ! -name "$(basename $RESULTS_FILE)" | sort -r | head -1)

        if [[ -n "$prev_result" ]]; then
            local prev_duration=$(grep "Total Duration:" "$prev_result" | awk '{print $3}' | sed 's/s//')
            local curr_duration=$(grep "Total Duration:" "$RESULTS_FILE" | awk '{print $3}' | sed 's/s//')

            if [[ -n "$prev_duration" ]] && [[ -n "$curr_duration" ]]; then
                local diff=$((curr_duration - prev_duration))
                local percent=$(awk "BEGIN {printf \"%.2f\", ($diff / $prev_duration) * 100}")

                echo "" >> "$RESULTS_FILE"
                echo "==================================================" >> "$RESULTS_FILE"
                echo "Comparison with Previous Run" >> "$RESULTS_FILE"
                echo "==================================================" >> "$RESULTS_FILE"
                echo "Previous Duration: ${prev_duration}s" >> "$RESULTS_FILE"
                echo "Current Duration: ${curr_duration}s" >> "$RESULTS_FILE"
                echo "Difference: ${diff}s (${percent}%)" >> "$RESULTS_FILE"
                echo "==================================================" >> "$RESULTS_FILE"

                if [[ $diff -lt 0 ]]; then
                    log_success "Performance improved by ${diff#-}s (${percent#-}%)"
                elif [[ $diff -gt 0 ]]; then
                    log_warning "Performance degraded by ${diff}s (${percent}%)"
                else
                    log_info "Performance unchanged"
                fi
            fi
        fi
    else
        log_info "No previous benchmarks to compare"
    fi
}

# Display summary
show_summary() {
    log_step "Benchmark Summary"

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Benchmark Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    log_info "Results saved to: $RESULTS_FILE"
    echo ""

    # Display key metrics if available
    if grep -q "Total Duration:" "$RESULTS_FILE"; then
        local duration=$(grep "Total Duration:" "$RESULTS_FILE" | awk '{print $3}')
        log_info "Total Duration: $duration"
    fi

    echo ""
    log_info "View full results: cat $RESULTS_FILE"
    log_info "View all benchmarks: ls -lh $BENCHMARK_DIR/"
    echo ""
}

# Cleanup old benchmarks
cleanup_old_benchmarks() {
    local keep_count="${1:-10}"

    log_step "Cleaning up old benchmarks (keeping last $keep_count)..."

    local total_count=$(find "$BENCHMARK_DIR" -name "results-*.txt" -type f | wc -l)

    if [[ $total_count -gt $keep_count ]]; then
        find "$BENCHMARK_DIR" -name "results-*.txt" -type f | sort | head -n -$keep_count | xargs rm -f
        local removed=$((total_count - keep_count))
        log_success "Removed $removed old benchmark files"
    else
        log_info "No cleanup needed (only $total_count benchmarks stored)"
    fi
}

# Main execution
main() {
    local playbook="${1:-playbooks/main.yml}"
    local check_mode="${2:-true}"

    show_header
    setup_benchmark_dir
    capture_system_info
    run_benchmark "$playbook" "$check_mode"
    analyze_results
    compare_benchmarks
    cleanup_old_benchmarks 10
    show_summary
}

# Parse arguments
PLAYBOOK="playbooks/main.yml"
CHECK_MODE="true"

while [[ $# -gt 0 ]]; do
    case $1 in
        --playbook)
            PLAYBOOK="$2"
            shift 2
            ;;
        --real-run)
            CHECK_MODE="false"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --playbook PATH    Specify playbook to benchmark (default: playbooks/main.yml)"
            echo "  --real-run         Run actual playbook instead of check mode"
            echo "  --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Benchmark in check mode"
            echo "  $0 --real-run                         # Benchmark with real execution"
            echo "  $0 --playbook playbooks/ssh-keys.yml # Benchmark specific playbook"
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
trap 'log_error "Benchmark failed at line $LINENO"' ERR

# Run main function
main "$PLAYBOOK" "$CHECK_MODE"
