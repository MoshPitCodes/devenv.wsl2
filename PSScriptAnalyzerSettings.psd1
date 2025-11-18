@{
    # Severity levels: Error, Warning, Information
    # Only fail on Error severity
    Severity = @('Error')

    # Exclude specific rules that are not applicable for user-facing CLI scripts
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',  # Write-Host is appropriate for CLI scripts with colored output
        'PSUseShouldProcessForStateChangingFunctions',  # Not required for installation scripts
        'PSUseSingularNouns'  # Plural nouns are acceptable when the function operates on multiple items
    )

    # Include default rules
    IncludeDefaultRules = $true
}
