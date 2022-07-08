$DotfilesDirectory = Join-Path -Path $HOME -ChildPath ".dotfiles"

if (!(Test-Path $DotfilesDirectory)) {
    Write-Host "Cannot find the `.dotfiles` directory." -ForegroundColor "Red"
}
else {
    # Welcome message
    Clear-Host
    Write-Host "Welcome to .dotfiles for Microsoft Windows OS" -ForegroundColor "Yellow"
    Write-Host "Please do not use your device while the script is running." -ForegroundColor "Yellow"
    Write-Host "[!] Note: upon completion, the script will restart the computer." -ForegroundColor "Yellow"
    Write-Host $("*" * 72) -ForegroundColor "Yellow"

    # Load helpers
    Write-Host "Loading helpers: " -ForegroundColor "Yellow" -NoNewline

    Push-Location $DotfilesDirectory
    $SubDirectories = @("Directories", "Fonts", "Git", "Helpers",
        "PowerShell", "PowerToys", "VSCode", "Windows", "WindowsTerminal")
    $ExcludedScripts = @("Profile.ps1")
    $SubDirectories | ForEach-Object { Get-ChildItem -Path $_ -Filter "*.ps1" } | `
        Where-Object { $ExcludedScripts -notcontains $_.Name } | `
        ForEach-Object -process { Invoke-Expression ". $($_.FullName)" }
    Pop-Location

    Write-Host "Done."

    # Verify whether running as Administrator
    if (!(Test-Elevated)) {
        # Stop, and run as Administrator
        Write-Host 'Not running as Administrator, attempting to elevate...'
        $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
        Start-Process powershell.exe -Verb runAs -ArgumentList $arguments
        Start-Sleep -Seconds 3
        Stop-Process -Id $PID
    }

    Write-Host "Running PowerShell as administrator." -ForegroundColor "Green"

    # Save user configuration in persistence
    $DotfilesConfigFile = Join-Path $DotfilesDirectory -ChildPath "config.json"
    Set-ConfigurationFile -DotfilesConfigFile $DotfilesConfigFile
    
    # Load user configuration from persistence
    $Config = Get-ConfigurationFile -DotfilesConfigFile $DotfilesConfigFile

    # Act according to the user's configuration
    Invoke-InstallByConfigurationFile -Config $Config -DotfilesDirectory $DotfilesDirectory

    # Wrap up
    Write-Host "The process has finished." -ForegroundColor "Yellow"
    Write-Host "Restarting the computer in " -ForegroundColor "Yellow" -NoNewline
    10..1 | ForEach-Object {
        If ($_ -gt 1) { Write-Host "$_ seconds" -ForegroundColor "Yellow" }
        Else { Write-Host "$_ second" -ForegroundColor "Yellow" }
        Start-Sleep -Seconds 1
    }
    Restart-Computer
}