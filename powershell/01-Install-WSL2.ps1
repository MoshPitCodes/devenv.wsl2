#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Installs and configures WSL2 with Ubuntu distribution.

.DESCRIPTION
    This script automates the installation of WSL2 on Windows. It handles:
    - Enabling required Windows features (WSL and Virtual Machine Platform)
    - Automatic reboot handling with continuation via RunOnce registry
    - Installing Ubuntu distribution
    - Setting WSL2 as default version
    - Verification of successful installation

.PARAMETER SkipReboot
    Skip automatic reboot even if required. Use for manual reboot control.

.PARAMETER Phase2
    Internal parameter for post-reboot continuation. Do not use manually.

.PARAMETER Distribution
    WSL distribution to install. Default is "Ubuntu".

.EXAMPLE
    .\Install-WSL2.ps1
    Standard installation with automatic reboot handling.

.EXAMPLE
    .\Install-WSL2.ps1 -Distribution Ubuntu-22.04
    Install specific Ubuntu version.

.EXAMPLE
    .\Install-WSL2.ps1 -SkipReboot
    Install features but skip automatic reboot.
#>

[CmdletBinding()]
param(
    [switch]$SkipReboot,
    [switch]$Phase2,
    [string]$Distribution = "Ubuntu"
)

# Color output helpers
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

function Test-WSLInstalled {
    <#
    .SYNOPSIS
        Checks if WSL feature is enabled.
    #>
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"
    return ($wslFeature.State -eq "Enabled")
}

function Test-VMPlatformInstalled {
    <#
    .SYNOPSIS
        Checks if Virtual Machine Platform feature is enabled.
    #>
    $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform"
    return ($vmFeature.State -eq "Enabled")
}

function Install-WSLFeatures {
    <#
    .SYNOPSIS
        Enables WSL and Virtual Machine Platform features.
    .OUTPUTS
        Boolean indicating if reboot is required.
    #>
    Write-StatusMessage "Installing WSL features..." "Info"

    $needsReboot = $false

    # Enable WSL feature
    if (-not (Test-WSLInstalled)) {
        Write-StatusMessage "Enabling Windows Subsystem for Linux..." "Info"
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
        if ($result.RestartNeeded) {
            $needsReboot = $true
            Write-StatusMessage "WSL feature enabled (reboot required)" "Warning"
        }
    } else {
        Write-StatusMessage "WSL feature already enabled" "Success"
    }

    # Enable Virtual Machine Platform
    if (-not (Test-VMPlatformInstalled)) {
        Write-StatusMessage "Enabling Virtual Machine Platform..." "Info"
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
        if ($result.RestartNeeded) {
            $needsReboot = $true
            Write-StatusMessage "Virtual Machine Platform enabled (reboot required)" "Warning"
        }
    } else {
        Write-StatusMessage "Virtual Machine Platform already enabled" "Success"
    }

    return $needsReboot
}

function Install-WSLDistribution {
    <#
    .SYNOPSIS
        Installs specified WSL distribution.
    #>
    param([string]$Distro)

    Write-StatusMessage "Setting WSL default version to 2..." "Info"
    try {
        wsl --set-default-version 2
        Write-StatusMessage "WSL2 set as default version" "Success"
    }
    catch {
        Write-StatusMessage "Note: WSL2 will be set as default after first distribution installation" "Warning"
    }

    Write-StatusMessage "Installing $Distro distribution..." "Info"
    Write-StatusMessage "This may take several minutes..." "Info"

    try {
        wsl --install -d $Distro --no-launch
        Write-StatusMessage "$Distro installed successfully" "Success"
    }
    catch {
        Write-StatusMessage "Failed to install $Distro : $_" "Error"
        throw
    }

    Write-StatusMessage "`nVerifying installation..." "Info"
    wsl --list --verbose
}

function Set-PostRebootContinuation {
    <#
    .SYNOPSIS
        Sets up script to continue after reboot using RunOnce registry key.
    #>
    param([string]$ScriptPath, [string]$Distribution)

    $runOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $commandLine = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File `"$ScriptPath`" -Phase2 -Distribution $Distribution"

    try {
        Set-ItemProperty -Path $runOnceKey -Name "WSLSetup" -Value $commandLine
        Write-StatusMessage "Post-reboot continuation configured" "Success"
    }
    catch {
        Write-StatusMessage "Failed to set RunOnce key: $_" "Error"
        Write-StatusMessage "You will need to run this script manually after reboot with -Phase2 flag" "Warning"
    }
}

function Show-CompletionMessage {
    <#
    .SYNOPSIS
        Displays completion instructions to user.
    #>
    param([string]$Distribution)

    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  WSL2 Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green

    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "1. Launch $Distribution from the Start Menu to complete user setup" -ForegroundColor White
    Write-Host "2. Create your Linux username and password when prompted" -ForegroundColor White
    Write-Host "3. Run the Configure-WSL2.ps1 script to optimize WSL settings" -ForegroundColor White
    Write-Host "4. Clone this repository in WSL and run ansible/bootstrap.sh to set up Ansible" -ForegroundColor White

    Write-Host "`nUseful Commands:" -ForegroundColor Cyan
    Write-Host "  Start WSL:           wsl" -ForegroundColor White
    Write-Host "  Start specific:      wsl -d $Distribution" -ForegroundColor White
    Write-Host "  List distributions:  wsl --list --verbose" -ForegroundColor White
    Write-Host "  Shutdown WSL:        wsl --shutdown" -ForegroundColor White
    Write-Host "  Check status:        wsl --status" -ForegroundColor White

    Write-Host ""
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    if (-not $Phase2) {
        # ====================================================================
        # Phase 1: Pre-Reboot
        # ====================================================================
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  WSL2 Installation - Phase 1" -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        Write-StatusMessage "Checking system requirements..." "Info"

        # Check if running as administrator
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-StatusMessage "This script must be run as Administrator" "Error"
            exit 1
        }

        # Install features
        $needsReboot = Install-WSLFeatures

        if ($needsReboot -and -not $SkipReboot) {
            Write-Host "`n========================================" -ForegroundColor Yellow
            Write-Host "  System Restart Required" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Yellow
            Write-StatusMessage "`nThe script will automatically continue after restart." "Info"
            Write-StatusMessage "Setting up post-reboot continuation..." "Info"

            $scriptPath = $MyInvocation.MyCommand.Path
            Set-PostRebootContinuation -ScriptPath $scriptPath -Distribution $Distribution

            Write-Host "`nRebooting in 15 seconds..." -ForegroundColor Yellow
            Write-Host "Press Ctrl+C to cancel..." -ForegroundColor Yellow
            Start-Sleep -Seconds 15

            Restart-Computer -Force
        }
        elseif ($needsReboot -and $SkipReboot) {
            Write-StatusMessage "`nReboot required but skipped due to -SkipReboot flag" "Warning"
            Write-StatusMessage "Please reboot and run this script with -Phase2 flag" "Warning"
            exit 0
        }
        else {
            Write-StatusMessage "`nNo reboot required. Proceeding to Phase 2..." "Success"
            & $MyInvocation.MyCommand.Path -Phase2 -Distribution $Distribution
        }
    }
    else {
        # ====================================================================
        # Phase 2: Post-Reboot
        # ====================================================================
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  WSL2 Installation - Phase 2" -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        Write-StatusMessage "Continuing after reboot..." "Info"

        # Wait a moment for services to stabilize
        Write-StatusMessage "Waiting for system to stabilize..." "Info"
        Start-Sleep -Seconds 5

        # Verify features are enabled
        if (-not (Test-WSLInstalled)) {
            Write-StatusMessage "WSL feature is not enabled. Installation may have failed." "Error"
            exit 1
        }

        if (-not (Test-VMPlatformInstalled)) {
            Write-StatusMessage "Virtual Machine Platform is not enabled. Installation may have failed." "Error"
            exit 1
        }

        Write-StatusMessage "All required features are enabled" "Success"

        # Install distribution
        Install-WSLDistribution -Distro $Distribution

        # Show completion message
        Show-CompletionMessage -Distribution $Distribution
    }
}
catch {
    Write-StatusMessage "`nInstallation failed: $_" "Error"
    Write-StatusMessage $_.ScriptStackTrace "Error"
    exit 1
}
