function Test-VSCodeExistence() {
    if ($env:TERM_PROGRAM -eq "vscode") {
        Write-Host "Visual Studio Code is currently being used, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    elseif (Get-Command "code" -ErrorAction SilentlyContinue) {
        Write-Host "Visual Studio Code is installed, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    return $FALSE
}

function Install-VSCode() {    
    Write-Host "Installing Visual Studio Code:" -ForegroundColor "Yellow"

    winget install --id "Microsoft.VisualStudioCode" --exact --source winget --force --accept-package-agreements

    Write-Host "Visual Studio Code has been successfully installed." -ForegroundColor "Green"
}

function Install-VSCodeExtensions() {    
    Write-Host "Installing Visual Studio Code extensions:" -ForegroundColor "Yellow"

    # Languages
    code --install-extension "formulahendry.auto-rename-tag"
    code --install-extension "ecmel.vscode-html-css"
    code --install-extension "yzhang.markdown-all-in-one"
    code --install-extension "ms-vscode.powershell"
    code --install-extension "hashicorp.terraform"
    code --install-extension "redhat.vscode-yaml"
    code --install-extension "robole.markdown-snippets"

    # IDE Tools
    code --install-extension "ritwickdey.LiveServer"
    code --install-extension "streetsidesoftware.code-spell-checker"
    code --install-extension "esbenp.prettier-vscode"
    code --install-extension "formulahendry.code-runner"

    # IDE Themes
    code --install-extension "zhuangtongfa.material-theme"
    code --install-extension "PKief.material-icon-theme"

    Write-Host "Visual Studio Code extensions has been successfully installed." -ForegroundColor "Green"
}

function Set-VSCodeConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesDirectory
    )

    $DotFilesVSCodePath = Join-Path $DotfilesDirectory -ChildPath "VSCode"
    $VSCodeSettingsPath = Join-Path -Path $env:APPDATA -ChildPath "Code" | Join-Path -ChildPath "User"
  
    if (-not (Test-Path -Path $VSCodeSettingsPath)) {
        Write-Host "Could not find Visual Studio Code settings directory." -ForegroundColor "Red"
    }
    else {
        Get-ChildItem -Path "${DotFilesVSCodePath}\*" -Include "*.json" -Recurse | Copy-Item -Destination $VSCodeSettingsPath
    }
}