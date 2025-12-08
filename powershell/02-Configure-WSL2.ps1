#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configures WSL2 settings for optimal performance.

.DESCRIPTION
    Creates and configures .wslconfig file in the user's home directory
    to optimize WSL2 resource allocation and behavior.

.PARAMETER Memory
    Memory allocation for WSL2 (e.g., "4GB", "8GB"). Default is 4GB.

.PARAMETER Processors
    Number of CPU cores to allocate. Default is 2.

.PARAMETER Swap
    Swap size (e.g., "1GB", "2GB"). Default is 1GB.

.PARAMETER LocalhostForwarding
    Enable localhost forwarding. Default is $true.

.PARAMETER Force
    Overwrite existing .wslconfig file without prompting.

.EXAMPLE
    .\Configure-WSL2.ps1
    Create .wslconfig with default settings.

.EXAMPLE
    .\Configure-WSL2.ps1 -Memory "8GB" -Processors 4 -Swap "2GB"
    Create .wslconfig with custom resource allocation.

.EXAMPLE
    .\Configure-WSL2.ps1 -Force
    Overwrite existing .wslconfig without confirmation.
#>

[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+[GM]B$', ErrorMessage = "Memory must be in format like '4GB' or '512MB'")]
    [string]$Memory = "4GB",

    [ValidateRange(1, 128)]
    [int]$Processors = 2,

    [ValidatePattern('^[0-9]+[GM]B$', ErrorMessage = "Swap must be in format like '1GB' or '512MB'")]
    [string]$Swap = "1GB",

    [bool]$LocalhostForwarding = $true,
    [switch]$Force
)

# Additional runtime validation
function Test-ConfigurationParameters {
    param(
        [string]$Memory,
        [int]$Processors,
        [string]$Swap
    )

    $resources = Get-SystemResources
    $errors = @()

    # Validate processor count against system
    if ($Processors -gt $resources.LogicalProcessors) {
        $errors += "Requested $Processors processors but system only has $($resources.LogicalProcessors)"
    }

    # Parse and validate memory
    $memValue = [int]($Memory -replace '[^0-9]', '')
    $memUnit = $Memory -replace '[0-9]', ''
    $memGB = if ($memUnit -eq 'MB') { $memValue / 1024 } else { $memValue }

    if ($memGB -gt $resources.TotalMemoryGB) {
        $errors += "Requested ${Memory} but system only has $($resources.TotalMemoryGB)GB total"
    }

    if ($memGB -gt ($resources.TotalMemoryGB * 0.9)) {
        Write-StatusMessage "Warning: Allocating more than 90% of system RAM to WSL2" "Warning"
    }

    # Parse and validate swap
    $swapValue = [int]($Swap -replace '[^0-9]', '')
    $swapUnit = $Swap -replace '[0-9]', ''
    $swapGB = if ($swapUnit -eq 'MB') { $swapValue / 1024 } else { $swapValue }

    if ($swapGB -gt 32) {
        Write-StatusMessage "Warning: Swap size of ${Swap} is unusually large" "Warning"
    }

    return $errors
}

function Write-StatusMessage {
    param([string]$Message, [string]$Level = "Info")

    $color = switch ($Level) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Info" { "Cyan" }
        default { "White" }
    }

    Write-Host $Message -ForegroundColor $color
}

function New-WSLConfig {
    <#
    .SYNOPSIS
        Creates .wslconfig file with specified settings.
    #>
    param(
        [string]$ConfigPath,
        [string]$Memory,
        [int]$Processors,
        [string]$Swap,
        [bool]$LocalhostForwarding
    )

    $config = @"
# WSL2 Configuration File
# Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
#
# This file configures settings for all WSL2 distributions.
# After making changes, run: wsl --shutdown
# Settings will apply on next WSL startup (wait ~8 seconds after shutdown)

[wsl2]

# Memory allocation
# Default: 50% of total RAM on Windows builds < 20175
# Default: 80% of total RAM on Windows builds >= 20175
# Format: <number><unit> where unit is GB or MB
memory=$Memory

# Number of virtual processors
# Default: Same as number of logical processors on Windows
processors=$Processors

# Swap size
# Default: 25% of memory size rounded up to nearest GB
# Set to 0 to disable swap
swap=$Swap

# Localhost forwarding
# Allows accessing Windows services from WSL using localhost
# Default: true
localhostForwarding=$($LocalhostForwarding.ToString().ToLower())

# Additional options (uncommented as needed):

# Kernel command line parameters
# kernelCommandLine =

# Swap file path
# Default: %USERPROFILE%\AppData\Local\Temp\swap.vhdx
# swapFile=C:\\temp\\wsl-swap.vhdx

# Disable page reporting (may improve performance)
# Default: true
# pageReporting=false

# Nested virtualization support
# Allows running VMs inside WSL2 (requires CPU support)
# Default: true
nestedVirtualization=true

# Enable debug console
# Default: false
# debugConsole=false

# GUI applications support (WSLg)
# Default: true
guiApplications=true

# DNS tunneling (for VPN compatibility)
# Default: false
# dnsTunneling=false

# Network mode: NAT (default) or mirrored (Windows 11 22H2+)
# mirrored mode: WSL shares same network interface as Windows
# Default: NAT
# networkingMode=mirrored

# Automatically reclaim cached memory (Windows 11 22H2+)
# Default: disabled
# autoMemoryReclaim=gradual  # or dropcache
"@

    try {
        Set-Content -Path $ConfigPath -Value $config -Encoding UTF8
        Write-StatusMessage "Configuration file created: $ConfigPath" "Success"
        return $true
    }
    catch {
        Write-StatusMessage "Failed to create configuration file: $_" "Error"
        return $false
    }
}

function Show-CurrentConfig {
    <#
    .SYNOPSIS
        Displays current .wslconfig if it exists.
    #>
    param([string]$ConfigPath)

    if (Test-Path $ConfigPath) {
        Write-StatusMessage "`nCurrent configuration:" "Info"
        Write-Host (Get-Content $ConfigPath -Raw) -ForegroundColor Gray
    }
}

function Get-SystemResources {
    <#
    .SYNOPSIS
        Gets system resource information for recommendations.
    #>
    $totalMemoryGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $logicalProcessors = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors

    return @{
        TotalMemoryGB = $totalMemoryGB
        LogicalProcessors = $logicalProcessors
    }
}

function Show-Recommendations {
    <#
    .SYNOPSIS
        Shows resource allocation recommendations based on system specs.
    #>
    $resources = Get-SystemResources

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  System Resources" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total RAM:        $($resources.TotalMemoryGB) GB" -ForegroundColor White
    Write-Host "CPU Cores:        $($resources.LogicalProcessors)" -ForegroundColor White

    Write-Host "`nRecommended WSL2 Allocation:" -ForegroundColor Cyan
    $recommendedMemory = [math]::Floor($resources.TotalMemoryGB * 0.5)
    $recommendedProcs = [math]::Max(2, [math]::Floor($resources.LogicalProcessors / 2))
    Write-Host "Memory:           $recommendedMemory GB (50% of total)" -ForegroundColor White
    Write-Host "Processors:       $recommendedProcs (50% of total)" -ForegroundColor White
    Write-Host ""
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  WSL2 Configuration" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Show system resources
    Show-Recommendations

    # Validate parameters against system resources
    Write-StatusMessage "Validating configuration parameters..." "Info"
    $validationErrors = Test-ConfigurationParameters -Memory $Memory -Processors $Processors -Swap $Swap

    if ($validationErrors.Count -gt 0) {
        Write-StatusMessage "Configuration validation errors:" "Error"
        foreach ($err in $validationErrors) {
            Write-StatusMessage "  - $err" "Error"
        }

        if (-not $Force) {
            $response = Read-Host "`nContinue anyway? (y/N)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-StatusMessage "Configuration cancelled due to validation errors" "Warning"
                exit 1
            }
        } else {
            Write-StatusMessage "Continuing despite errors due to -Force flag" "Warning"
        }
    } else {
        Write-StatusMessage "Configuration parameters validated" "Success"
    }

    # Configuration file path
    $configPath = "$env:USERPROFILE\.wslconfig"

    # Check if config already exists
    if (Test-Path $configPath) {
        Show-CurrentConfig -ConfigPath $configPath

        if (-not $Force) {
            Write-Host "`n.wslconfig file already exists!" -ForegroundColor Yellow
            $response = Read-Host "Do you want to overwrite it? (y/N)"

            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-StatusMessage "Configuration cancelled by user" "Warning"
                exit 0
            }
        }
        else {
            Write-StatusMessage ".wslconfig exists but -Force specified, overwriting..." "Warning"
        }

        # Backup existing config
        $backupPath = "$configPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -Path $configPath -Destination $backupPath
        Write-StatusMessage "Existing config backed up to: $backupPath" "Info"
    }

    # Create new configuration
    Write-StatusMessage "`nCreating new .wslconfig..." "Info"
    Write-StatusMessage "Memory: $Memory" "Info"
    Write-StatusMessage "Processors: $Processors" "Info"
    Write-StatusMessage "Swap: $Swap" "Info"
    Write-StatusMessage "Localhost Forwarding: $LocalhostForwarding" "Info"

    $success = New-WSLConfig -ConfigPath $configPath `
                            -Memory $Memory `
                            -Processors $Processors `
                            -Swap $Swap `
                            -LocalhostForwarding $LocalhostForwarding

    if ($success) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  Configuration Complete" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green

        Write-Host "`nNext Steps:" -ForegroundColor Cyan
        Write-Host "1. Shutdown WSL to apply settings:" -ForegroundColor White
        Write-Host "   wsl --shutdown" -ForegroundColor Yellow
        Write-Host "`n2. Wait 8 seconds for WSL to fully shutdown" -ForegroundColor White
        Write-Host "`n3. Start WSL again:" -ForegroundColor White
        Write-Host "   wsl" -ForegroundColor Yellow
        Write-Host "`n4. Verify settings inside WSL:" -ForegroundColor White
        Write-Host "   # Check memory" -ForegroundColor Gray
        Write-Host "   free -h" -ForegroundColor Yellow
        Write-Host "   # Check CPUs" -ForegroundColor Gray
        Write-Host "   nproc" -ForegroundColor Yellow

        Write-Host "`nConfiguration file location:" -ForegroundColor Cyan
        Write-Host "$configPath" -ForegroundColor White
        Write-Host ""

        # Ask if user wants to apply now
        $apply = Read-Host "`nShutdown WSL now to apply settings? (y/N)"
        if ($apply -eq 'y' -or $apply -eq 'Y') {
            Write-StatusMessage "Shutting down WSL..." "Info"
            wsl --shutdown
            Write-StatusMessage "WSL shutdown complete. Settings will apply on next startup." "Success"
            Write-StatusMessage "Wait 8 seconds before starting WSL again." "Warning"
        }
    }
    else {
        Write-StatusMessage "Configuration failed" "Error"
        exit 1
    }
}
catch {
    Write-StatusMessage "`nConfiguration failed: $_" "Error"
    Write-StatusMessage $_.ScriptStackTrace "Error"
    exit 1
}
