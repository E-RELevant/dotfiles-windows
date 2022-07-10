function Set-ConfigurationFile() {
    [CmdletBinding()]
    Param (
        [Parameter( Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesConfigFile,

        [Parameter( Position = 1, Mandatory = $FALSE)]
        [bool]
        $Override = $FALSE
    )

    $ConfigJsonBody = [ordered]@{}

    if ($Override -or (-not (Test-Path -Path $DotfilesConfigFile))) {
        
        Write-Host "Setting up a new config.json:" -ForegroundColor "Yellow"
        
        # Sub-HashTables declaration
        $WindowsHash = [ordered]@{}
        $PowerShellHash = [ordered]@{}
        $WindowsTerminalHash = [ordered]@{}
        $GitHash = [ordered]@{}
        $VSCodeHash = [ordered]@{}

        # Git
        if (!(Test-GitExistance)) {
            $Reply = Prompt-ForChoice -Question "Would you like to install Git?"
            if ($Reply) {
                $GitHash.Add("Install", $TRUE)
            }
        }
        if (!$WindowsTerminalHash.Contains("Install")) {
            $GitHash.Add("Install", $FALSE)
        }
        $Reply = Prompt-ForChoice -Question "Would you like to configure Git settings?"
        if ($Reply) { 
            $GitHash.Add("UserName", (Read-Host "Please enter your Git Username"))
            $GitHash.Add("Email", (Read-Host "Please enter your Git email address"))
        }
        else {
            $GitHash.Add("UserName", "")
            $GitHash.Add("Email", "")
        }

        $ConfigJsonBody.Add("Git", $GitHash)

        # Nerd Font
        $Reply = Prompt-ForChoice -Question "Would you like to install a Nerd-Font?"
        $ConfigJsonBody.Add("NerdFont", $(if ($Reply) { (Set-NerdFont) } else { $FALSE }) )

        # PowerShell
        if (!(Test-PowerShellCoreExistance)) {
            $Reply = Prompt-ForChoice -Question "Would you like to install PowerShell Core?"
            if ($Reply) { $PowerShellHash.Add("InstallCore", $TRUE) }
        }
        if (!$WindowsTerminalHash.Contains("Install")) { $PowerShellHash.Add("InstallCore", $FALSE) }

        $Reply = Prompt-ForChoice -Question "Would you like to set the PowerShell Profile?"
        $PowerShellHash.Add("SetProfile", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $Reply = Prompt-ForChoice -Question "Would you like to install PowerShell Modules?"
        $PowerShellHash.Add("InstallModules", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $Reply = Prompt-ForChoice -Question "Would you like to install Oh My Posh?"
        $PowerShellHash.Add("InstallOhMyPosh", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $ConfigJsonBody.Add("PowerShell", $PowerShellHash)

        # PowerToys
        $Reply = Prompt-ForChoice -Question "Would you like to install PowerToys?"
        $ConfigJsonBody.Add("PowerToys", $(if ($Reply) { $TRUE } else { $FALSE }) )
        
        # Windows
        $Reply = Prompt-ForChoice -Question "Would you like to Set a PC name?"
        $WindowsHash.Add("ComputerName", $(if ($Reply) { (Read-Host "Please enter the name of the computer") } else { $FALSE }) )

        $Reply = Prompt-ForChoice -Question "Would you like to configure the power plan?"
        $WindowsHash.Add("SetPowerPlan", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $Reply = Prompt-ForChoice -Question "Would you like to configure explorer settings?"
        $WindowsHash.Add("SetExplorerSettings", $(if ($Reply) { $TRUE } else { $FALSE }) )
        
        $ConfigJsonBody.Add("Windows", $WindowsHash)

        # Windows Terminal
        if (!(Test-WindowsTerminalExistance)) {
            $Reply = Prompt-ForChoice -Question "Would you like to install Windows Terminal?"
            if ($Reply) { 
                $WindowsTerminalHash.Add("Install", $TRUE)
              
                $Options = @("winget", "msstore")
                $WindowsTerminalHash.Add("Source", (Select-FromArrayOptions -Array $Options))
            }
            else { 
                $WindowsTerminalHash.Add("Install", $FALSE)
                $WindowsTerminalHash.Add("Source", "")
            }
        }
        if (!$WindowsTerminalHash.Contains("Install")) {
            $WindowsTerminalHash.Add("Install", $FALSE)
            $WindowsTerminalHash.Add("Source", "")
        }
        $Reply = Prompt-ForChoice -Question "Would you like to configure Windows Terminal settings?"
        $WindowsTerminalHash.Add("ConfigureSettings", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $ConfigJsonBody.Add("WindowsTerminal", $WindowsTerminalHash)
        
        # Visual Studio Code
        if (!(Test-VSCodeExistence)) {
            $Reply = Prompt-ForChoice -Question "Would you like to install Visual Studio Code?"
            if ($Reply) {
                $VSCodeHash.Add("Install", $TRUE)
            }
        }
        if (!$VSCodeHash.Contains("Install")) { $VSCodeHash.Add("Install", $FALSE) }

        $Reply = Prompt-ForChoice -Question "Would you like to install Visual Studio Code extensions?"
        $VSCodeHash.Add("InstallExtensions", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $Reply = Prompt-ForChoice -Question "Would you like to configure Visual Studio Code settings?"
        $VSCodeHash.Add("ConfigureSettings", $(if ($Reply) { $TRUE } else { $FALSE }) )

        $ConfigJsonBody.Add("VSCode", $VSCodeHash)

        # Workspace directory
        $Reply = Prompt-ForChoice -Question "Would you like to set up a 'Workspace' directory?"
        $ConfigJsonBody.Add("WorkspaceDisk", $(if ($Reply) { (Set-WorkspaceDisk) } else { $FALSE }) )

        # Generate
        if ($Override) {
            Write-Host "Overriding the existing 'config.json' file." -ForegroundColor "Yellow"
            Remove-Item $DotfilesConfigFile -ErrorAction SilentlyContinue
        }
        else { Write-Host "Creating config.json file:" -ForegroundColor "Yellow" }
  
        Set-Content -Path $DotfilesConfigFile -Value ($ConfigJsonBody | ConvertTo-Json)
  
        Write-Host "config.json file has been successfully created." -ForegroundColor "Green"

        $Reply = Prompt-ForChoice -Question "Would you like to execute the script right now?"
        if (!$Reply) { 
            Write-Host "You can always find me at " -ForegroundColor "Yellow" -NoNewline
            Write-Host "'$($HOME)\.dotfiles'."
            Start-Sleep -Seconds 3
            
            Write-Host "Bye-bye." -ForegroundColor "Yellow"
            Start-Sleep -Seconds 1
            
            exit
        }
    }
    else {
        Write-Host "'config.json' file exists already." -ForegroundColor "Yellow"
        $Reply = Prompt-ForChoice -Question "Would you like to use the current 'config.json'?"

        if ($Reply -eq $FALSE) {
            Set-ConfigurationFile -DotfilesConfigFile $DotfilesConfigFile -Override $TRUE
        }
    }
}
 
function Get-ConfigurationFile() {
    [CmdletBinding()]
    Param (
        [Parameter( Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesConfigFile
    )
    
    $ConfigContent = Get-Content $DotfilesConfigFile | ConvertFrom-Json

    Write-Host "Reading config.json file:" -ForegroundColor "Yellow"

    $Config = Convert-PSObjectToHashtable $ConfigContent

    Write-Host "config.json contains:" -ForegroundColor "Yellow"
    Write-Host -ForegroundColor "Yellow" ($Config | Out-String)

    return $Config
}

function Invoke-InstallByConfigurationFile() {
    [CmdletBinding()]
    Param (
        [Parameter( Position = 0, Mandatory = $TRUE)]
        [PSObject]
        $Config,

        [Parameter( Position = 0, Mandatory = $TRUE)]
        [String]
        $DotfilesDirectory
    )
    
    $InstallNerdFont = $FALSE

    # Git
    if ($Config.ContainsKey("Git")) {
        if ($Config["Git"].Install -eq $TRUE) { Install-Git }
        if (($null -ne $Config["Git"].UserName) -and ($null -ne $Config["Git"].Email)) {
            Set-GitConfiguration -GitUsername $Config["Git"].UserName -GitEmail $Config["Git"].Email
        }
    }

    # Nerd Font
    if (($Config.ContainsKey("NerdFont")) -and ($Config["NerdFont"] -ne $FALSE)) { 
        Install-NerdFont -File $Config["NerdFont"]
        $InstallNerdFont = $TRUE
    }

    # PowerShell
    if ($Config.ContainsKey("PowerShell")) {
        if ($Config["PowerShell"].InstallCore -eq $TRUE) { Install-PowerShellCore }
        if ($Config["PowerShell"].SetProfile -eq $TRUE) { 
            Set-PowerShellProfile -DotfilesDirectory $DotfilesDirectory -PowerShellConfig $Config["PowerShell"]
        }
        if ($Config["PowerShell"].InstallModules -eq $TRUE) { 
            # Trust PSGallery
            if (-not (Get-PSRepositoryTrustedStatus -PSRepositoryName "PSGallery")) {
                Write-Host "Setting up PSGallery as PowerShell trusted repository: " -ForegroundColor "Yellow" -NoNewline
                Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
                Write-Host "Done."
            }
            Install-PowerShellModules
        }
        if ($Config["PowerShell"].InstallOhMyPosh -eq $TRUE) { }
    }

    # PowerToys
    if (($Config.ContainsKey("PowerToys")) -and ($Config["PowerToys"] -eq $TRUE)) { 
        Install-PowerToys
    }

    # Windows
    if ($Config.ContainsKey("Windows")) { 
        if ($Config["Windows"].ComputerName -ne $FALSE) { Rename-PC -Name $Config["Windows"].ComputerName }
        if ($Config["Windows"].SetPowerPlan -eq $TRUE) { Set-PowerPlan }
        if ($Config["Windows"].SetExplorerSettings -eq $TRUE) { Set-ExplorerSettings }
    }

    # Windows Terminal
    if ($Config.ContainsKey("WindowsTerminal")) { 
        if ($Config["WindowsTerminal"].Install -eq $TRUE) {
            Install-WindowsTerminal -Option $Config["WindowsTerminal"].Source
        }
        if ($Config["WindowsTerminal"].ConfigureSettings -eq $TRUE) {
            if ($InstallNerdFont) { Set-WindowsTerminalConfiguration -DotfilesDirectory $DotfilesDirectory -ConfigNerdFont $Config["NerdFont"] }
            else { Set-WindowsTerminalConfiguration -DotfilesDirectory $DotfilesDirectory -ConfigNerdFont $FALSE }
        }
    }
    
    # Visual Studio Code
    if ($Config.ContainsKey("VSCode")) {
        if ($Config["VSCode"].Install -eq $TRUE) { Install-VSCode }
        if ($Config["VSCode"].InstallExtensions -eq $TRUE) { Install-VSCodeExtensions }
        if ($Config["VSCode"].ConfigureSettings -eq $TRUE) {
            Set-VSCodeConfiguration -DotfilesDirectory $DotfilesDirectory
        }
    }

    # Workspace directory
    if (($Config.ContainsKey("WorkspaceDisk")) -and ($Config["WorkspaceDisk"] -ne $FALSE)) { 
        Set-WorkspaceDirectory -WorkspaceDisk $Config["WorkspaceDisk"]
    }
}