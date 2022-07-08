function Install-PowerToys() {    
    Write-Host "Installing PowerToys:" -ForegroundColor "Yellow"

    winget install --id "Microsoft.PowerToys" --exact --source winget --force --accept-package-agreements

    Write-Host "PowerToys has been successfully installed." -ForegroundColor "Green"
}