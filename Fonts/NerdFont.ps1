function Install-NerdFont() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $File
    )

    $Name = $File.Split(".")[0]
    $ExistingFonts = 0

    Write-Host "Installing $($Name) Nerd-Font:" -ForegroundColor "Yellow"

    $Repo = "ryanoasis/nerd-fonts"
    $Releases = "https://api.github.com/repos/$repo/releases/latest"

    Write-Host "Determining latest release: " -ForegroundColor "Yellow" -NoNewline
    $Tag = (Invoke-WebRequest $Releases | ConvertFrom-Json)[0].tag_name
    Write-Host $Tag

    $Download = "https://github.com/$Repo/releases/download/$Tag/$File"
    
    $Zip = "$Name-$Tag.zip"
    $Dir = "$Name-$Tag"

    $ZipFullPath = Join-Path $HOME -ChildPath "Downloads" | Join-Path -ChildPath $Zip
    $DirFullPath = Join-Path $HOME -ChildPath "Downloads" | Join-Path -ChildPath $Dir

    # Download
    Write-Host "Dowloading latest release: " -ForegroundColor "Yellow" -NoNewline
    Invoke-WebRequest $Download -Out $ZipFullPath
    Write-Host "Done."

    Write-Host "Extracting release files: " -ForegroundColor "Yellow" -NoNewline
    Expand-Archive $ZipFullPath -DestinationPath $DirFullPath -Force
    Write-Host "Done."

    $Fonts = 0x14
    $ObjShell = New-Object -ComObject Shell.Application
    $ObjFontsDirectory = $ObjShell.Namespace($Fonts)

    # Install
    Write-Host "Installing the font-family: " -ForegroundColor "Yellow" -NoNewline
    $Fonts = Get-ChildItem -Path $DirFullPath | Where-Object { $_.Extension -eq ".ttf" }
    $InstalledFonts = @(Get-ChildItem (Join-Path "C:\" -ChildPath "Windows" | Join-Path -ChildPath "Fonts") | `
            Where-Object { $_.PSIsContainer -eq $FALSE } | Select-Object BaseName)

    foreach ($Font in $Fonts) {
        $Copy = $TRUE
        $FontName = $Font.BaseName -replace "_", ""

        foreach ($InstalledFont in $InstalledFonts) {
            $InstalledFontName = $InstalledFont.BaseName -replace "_", ""
            
            if ($InstalledFontName -match $FontName) { $Copy = $FALSE }
        }

        if ($Copy) { 
            Write-Host "Installing '$FontName'..." -ForegroundColor "Yellow"
            $ObjFontsDirectory.CopyHere($Font.FullName)
        }
        else { $ExistingFonts++ }
    }
    if ($ExistingFonts -gt 0) { Write-Host "$($ExistingFonts)/$($Fonts.Length) fonts were already installed ==> " -NoNewLine }
    Write-Host "Done."

    # Clean
    Write-Host "Removing temporary files: " -ForegroundColor "Yellow" -NoNewline
    Remove-Item $ZipFullPath -Force
    Remove-Item $DirFullPath -Recurse -Force
    Write-Host "Done."

    Write-Host "$($Name) Nerd-Font has been successfully installed." -ForegroundColor "Green"
}

function Set-NerdFont() {
    $NerdFonts = @()
    $Repo = "ryanoasis/nerd-fonts"
    $Releases = "https://api.github.com/repos/$Repo/releases/latest"

    Write-Host "Determining available Nerd Fonts: " -ForegroundColor "Yellow" -NoNewLine
    (Invoke-WebRequest $Releases | ConvertFrom-Json).assets | ForEach-Object {
        $NerdFonts += $_.Name.Split(".zip")[0]
    }
    Write-Host "Done."

    $Reply = Select-FromArrayOptions $NerdFonts
    return "$($NerdFonts | Select-String $Reply).zip"
}