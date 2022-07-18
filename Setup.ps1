$DotfilesDirectory = Join-Path -Path $HOME -ChildPath ".dotfiles"

if (!(Test-Path $DotfilesDirectory)) {
    Write-Host "Cannot find the `.dotfiles` directory." -ForegroundColor "Red"
}
else {
    # Welcome message
    Clear-Host
    Write-Host "Welcome to .dotfiles for Microsoft Windows OS" -ForegroundColor "Yellow"
    Write-Host $("*" * 72) -ForegroundColor "Yellow"

    # Load helpers
    Write-Host "Loading helpers: " -ForegroundColor "Yellow" -NoNewline

    Push-Location $DotfilesDirectory
    $SubDirectories = @("Directories", "Fonts", "Git", "Helpers",
        "PowerShell", "VSCode", "Windows", "WindowsTerminal")
    $ExcludedScripts = @("Profile.ps1")
    $SubDirectories | ForEach-Object { Get-ChildItem -Path $_ -Filter "*.ps1" } | `
        Where-Object { $ExcludedScripts -notcontains $_.Name } | `
        ForEach-Object -process { Invoke-Expression ". $($_.FullName)" }
    Pop-Location

    Write-Host "Done."

    # Verify whether running as Administrator
    if (!(Test-Elevated)) {
        # Stop, and run as Administrator
        Write-Warning "You are not running this as a 'Domain Admin' or 'Local Administrator' of $($ENV:COMPUTERNAME)."
        Write-Warning "The script will be re-executed as Local Administrator shortly."
        Start-Sleep 3

        # Build base arguments for powershell.exe as string array
        $ArgList = '-NoLogo', '-NoProfile', '-NoExit', '-ExecutionPolicy Bypass', '-File', ('"{0}"' -f $PSCommandPath)

        try {
            Start-Process PowerShell.exe -Verb "RunAs" -WorkingDirectory $PWD -ArgumentList $ArgList -Verbose -ErrorAction "Stop"
        
            # Exit the current script. 
            exit
        }
        catch { throw }
    }

    $CurrentLoginPrincipal = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent())
    Write-Host " $($CurrentLoginPrincipal.Identity.Name.ToString()) is currently running as a Local Administrator." -ForegroundColor "Green"

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