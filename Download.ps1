# Auxiliary variables
$GitHubRepositoryUri = "https://github.com/$($GitHubRepositoryAuthor)/$($GitHubRepositoryName)/archive/refs/heads/main.zip"
$DotfilesDirectory = Join-Path -Path $HOME -ChildPath ".dotfiles"
$ZipFullPath = Join-Path -Path $DotfilesDirectory -ChildPath "$($GitHubRepositoryName)-main.zip"
$DirFullPath = Join-Path -Path $DotfilesDirectory -ChildPath "$($GitHubRepositoryName)-main"

# Dotfiles directory
if (Test-Path $DotfilesDirectory) {
    Write-Host "There is an existing directory under $($DotfilesDirectory)." -ForegroundColor "Yellow"
    do {
        $Reply = Read-Host "Do you wish to replace the existing directory? [Y] Yes [N] No (default is 'N')"
    }
    while (-not ($Reply -match "^(?:y|yes|n|no|)$"))

    if ($Reply -match "^(?:n|no|)$") { exit }
    Remove-Item -Path $DotfilesDirectory -Recurse -Force
}
New-Item $DotfilesDirectory -ItemType directory

# Download
$IsDownloaded = $FALSE
Try {
    Invoke-WebRequest $GitHubRepositoryUri -O $ZipFullPath
    $IsDownloaded = $TRUE
}
catch [System.Net.WebException] {
    Write-Host "Error connecting to GitHub, please check your internet connection or the repository url." -ForegroundColor "Red"
}

if ($IsDownloaded) {
    # Extract
    Expand-Archive $ZipFullPath -DestinationPath $DotfilesDirectory -Force

    # Clean up
    Get-ChildItem –Path $DirFullPath -Recurse -Force | Move-Item -Destination $DotfilesDirectory -Force
    Remove-Item -Path $ZipFullPath -Force
    Remove-Item -Path $DirFullPath -Force
    
    # Invoke setup
    Invoke-Expression (Join-Path -Path $DotfilesDirectory -ChildPath "Setup.ps1")
}