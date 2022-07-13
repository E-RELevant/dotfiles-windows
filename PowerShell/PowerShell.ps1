function Test-PowerShellCoreExistance() {
    if ($PSVersionTable.PSEdition -eq "core") {
        Write-Host "PowerShell Core is currently being used, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    elseif (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) {
        Write-Host "PowerShell Core is installed, skipping." -ForegroundColor "Yellow"
        return $TRUE
    }
    return $FALSE
}

function Install-PowerShellCore() {
    Write-Host "Installing PowerShell Core:" -ForegroundColor "Yellow"

    winget install --id "Microsoft.PowerShell" --exact --source winget --force --accept-package-agreements

    Write-Host "PowerShell Core has been successfully installed." -ForegroundColor "Green"
}

function Set-PowerShellProfile() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesDirectory,
        
        [Parameter(Position = 1, Mandatory = $TRUE)]
        [HashTable]
        $PowerShellConfig
    )

    $PowerShellProfileTemplatePath = Join-Path $DotfilesDirectory -ChildPath "PowerShell" | `
        Join-Path -ChildPath "Profile.ps1"

    if ($PowerShellConfig.ContainsKey("InstallModules")) { 
        if ($Config["PowerShell"].InstallModules -eq $FALSE) { 
            Remove-PowerShellProfileSection -PowerShellProfilePath $PowerShellProfileTemplatePath `
                -SectionName "Import Modules"
        }
    }
    if ($PowerShellConfig.ContainsKey("InstallOhMyPosh")) { 
        if ($Config["PowerShell"].InstallOhMyPosh -eq $FALSE) { 
            Remove-PowerShellProfileSection -PowerShellProfilePath $PowerShellProfileTemplatePath `
                -SectionName "Oh My Posh"
        }
    }
    if ($PowerShellConfig.ContainsKey("Git")) { 
        if ($Config["Git"].Install -eq $FALSE) { 
            Remove-PowerShellProfileSection -PowerShellProfilePath $PowerShellProfileTemplatePath `
                -SectionName "Git Aliases"
        }
    }
    #if ($PowerShellConfig.ContainsKey("Docker")) { 
    #    if ($Config["Docker"].Install -eq $FALSE) { 
    #        Remove-PowerShellProfileSection -PowerShellProfilePath $PowerShellProfileTemplatePath `
    #            -SectionName "Docker Aliases"
    #    }
    #}

    Copy-PowerShellProfile -TemplateFilePath $PowerShellProfileTemplatePath
}

function Remove-PowerShellProfileSection() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $PowerShellProfilePath,

        [Parameter(Position = 1, Mandatory = $TRUE)]
        [String]
        $SectionName
    )

    $ProfileContent = Get-Content $PowerShellProfilePath
    $ProfileLineLength = (Get-Content $PowerShellProfilePath).Count - 1

    $start = 0..$ProfileLineLength | `
        Where-Object { $ProfileContent[$_] -match $SectionName } | `
        Select-Object -First 1
    
    if ($null -ne $start) {
        # The structure of each section is represented by 3 lines of a comment
        $stop = 0..$ProfileLineLength | `
            Where-Object { ($ProfileContent[$_] -match "##") -and ($_ -gt $start + 2) } | `
            Select-Object -First 1
        
        if ($null -eq $stop) {
            Get-Content $PowerShellProfilePath | `
                Where-Object { ($_.ReadCount -lt $start) } | `
                Set-Content "temp.ps1" 
        }
        else {
            Get-Content $PowerShellProfilePath | `
                Where-Object { ($_.ReadCount -lt $start) -or ($_.ReadCount -gt $stop) } | `
                Set-Content "temp.ps1"
        }

        Move-Item -Force "temp.ps1" $PowerShellProfilePath
    }
}
function Copy-PowerShellProfile() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $TemplateFilePath
    )

    Write-Host "Copying PowerShell profile:" -ForegroundColor "Yellow"
    
    $PowerShellProfile = $Profile

    # Force PowerShell profile (in case of other IDE, like VS Code)
    $PowerShellProfile = if ($PowerShellProfile -notmatch "Microsoft.PowerShell") { 
        (Join-Path (Split-Path -Parent $Profile) -ChildPath "Microsoft.PowerShell_profile.ps1")
    }

    Copy-Item $TemplateFilePath -Destination PowerShellProfile

    if (-not (Test-Path $TemplateFilePath)) {
        Write-Host "Could not create the PowerShell profile." -ForegroundColor "Red"
    }
    else {
        Write-Host "PowerShell profile has been successfully created." -ForegroundColor "Green"
    }
}

function Install-PowerShellModules() {    
    Write-Host "Installing PowerShell modules:" -ForegroundColor "Yellow"

    Install-Module -Name "posh-git" -Repository "PSGallery"
    Install-Module -Name "PSWebSearch" -Repository "PSGallery"
    Install-Module -Name "PSReadLine" -Repository "PSGallery" -Force # Might exist in an earlier version
    Install-Module -Name "Terminal-Icons" -Repository "PSGallery"
    Install-Module -Name "z" -Repository "PSGallery"

    Write-Host "PowerShell modules has been successfully installed." -ForegroundColor "Green"
}

function Install-OhMyPosh() {    
    Write-Host "Installing Oh My Posh:" -ForegroundColor "Yellow"

    winget install --id "JanDeDobbeleer.OhMyPosh" --exact --source winget --force --accept-package-agreements

    Write-Host "Oh My Posh has been successfully installed." -ForegroundColor "Green"
}