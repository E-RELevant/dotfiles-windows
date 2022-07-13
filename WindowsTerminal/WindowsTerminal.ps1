function Test-WindowsTerminalExistance() {
    if ($null -ne $env:WT_SESSION) {
        Write-Host "Windows Terminal is currently being used, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    elseif (Get-Command "wt.exe" -ErrorAction SilentlyContinue) {
        Write-Host "Windows Terminal is installed, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    return $FALSE
}

function Install-WindowsTerminal() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $Option
    )

    winget install "Windows Terminal" --source $Option --force --accept-package-agreements
}

function Set-WindowsTerminalConfiguration() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesDirectory,

        [Parameter(Position = 1, Mandatory = $TRUE)]
        [String]
        $ConfigNerdFont
    )

    Write-Host "Configuring Windows Terminal settings:" -ForegroundColor "Yellow"
    
    $LocalAppDataPackagesPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages"
    $WindowsTerminalSettingsPath = Join-Path (Get-ChildItem -Path $LocalAppDataPackagesPath -Filter "Microsoft.WindowsTerminal*") -ChildPath "LocalState" | `
        Join-Path -ChildPath "settings.json"

    $CustomActionsPath = Join-Path $DotfilesDirectory -ChildPath "WindowsTerminal" | Join-Path -ChildPath "customActions.json"
    $ProfileDefaultsPath = Join-Path $DotfilesDirectory -ChildPath "WindowsTerminal" | Join-Path -ChildPath "profileDefaults.json"

    if (-not (Test-Path $WindowsTerminalSettingsPath)) {
        Write-Host "Could not find Windows Terminal 'settings.json' file." -ForegroundColor "Red"
        return
    }
	
    # Add custom actions
    $Settings = Get-Content $WindowsTerminalSettingsPath | ConvertFrom-Json
	(Get-Content $CustomActionsPath | ConvertFrom-Json).actions | ForEach-Object {
        $Settings.actions += $_
    }
	
    # Set profile defaults
    if ($ConfigNerdFont -eq $FALSE) { $FontName = "Cascadia Mono" }
    else { $FontName = "$($ConfigNerdFont.Split(".")[0]) Nerd Font Mono" }
    (Get-Content -Path $ProfileDefaultsPath) -replace "<FONT_NAME>", $FontName | Set-Content -Path $ProfileDefaultsPath

    $Settings = (Get-Content $WindowsTerminalSettingsPath | ConvertFrom-Json)
    $Settings.profiles.defaults = (Get-Content $ProfileDefaultsPath | ConvertFrom-Json).defaults

    # Set
    $Settings | ConvertTo-Json -Depth 100 | Out-file $WindowsTerminalSettingsPath -Force
    
    Write-Host "Windows Terminal has been successfully configured." -ForegroundColor "Green"
}