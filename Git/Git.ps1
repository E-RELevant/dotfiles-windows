function Test-GitExistance() {
    if (Get-Command "git.exe" -ErrorAction SilentlyContinue) {
        Write-Host "Git is installed, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    return $FALSE
}

function Set-GitConfiguration() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $GitUsername,
        
        [Parameter(Position = 1, Mandatory = $TRUE)]
        [String]
        $GitEmail
    )

    Write-Host "Configuring Git:" -ForegroundColor "Yellow"
    git config --global init.defaultBranch "main"

    git config --global user.name $GitUsername
    
    git config --global user.email $GitEmail

    Write-Host "Git has been successfully configured." -ForegroundColor "Green"
}

function Install-Git() {
    winget install --id Git.Git --exact --source winget --force --accept-package-agreements
}