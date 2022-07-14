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

function Install-VSCodeExtensions() {    
    Write-Host "Installing Visual Studio Code extensions:" -ForegroundColor "Yellow"

    # Formatting and Rules
    code --install-extension "aaron-bond.better-comments"
    code --install-extension "esbenp.prettier-vscode"
    code --install-extension "ritwickdey.LiveServer"
    code --install-extension "streetsidesoftware.code-spell-checker"

    # IDE Themes
    code --install-extension "PKief.material-icon-theme"
    code --install-extension "zhuangtongfa.material-theme"

    # HTML and CSS
    code --install-extension "ecmel.vscode-html-css"
    code --install-extension "formulahendry.auto-rename-tag"

    # Markdown
    code --install-extension "davidanson.vscode-markdownlint"
    code --install-extension "robole.markdown-snippets"
    code --install-extension "yzhang.markdown-all-in-one"

    # Terraform
    code --install-extension "hashicorp.terraform"

    # PowerShell
    code --install-extension "ms-vscode.powershell"
    
    # YAML
    code --install-extension "redhat.vscode-yaml"

    Write-Host "Visual Studio Code extensions has been successfully installed." -ForegroundColor "Green"
}

function Set-VSCodeConfiguration() {
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