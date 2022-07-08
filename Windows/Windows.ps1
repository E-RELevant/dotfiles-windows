function Rename-PC {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $Name
    )

    if ($env:COMPUTERNAME -ne $Config.ComputerName) {
        Write-Host "Renaming PC:" -ForegroundColor "Yellow";
  
        Rename-Computer -NewName $Name -Force
  
        Write-Host "PC has been successfully renamed (a restart is required to see changes)." -ForegroundColor "Green"
    }
    else {
        Write-Host "The PC name is '$($Name)' already, skipping." -ForegroundColor "Green"
    }
}

function Edit-Registry {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $RegistryPath,
        
        [Parameter(Position = 1, Mandatory = $TRUE)]
        [String]
        $PropertyName,

        [Parameter(Position = 2, Mandatory = $TRUE)]
        [String]
        $PropertyValue,

        [Parameter(Position = 3, Mandatory = $FALSE)]
        [String]
        $PropertyType
    )
  
    try { Get-ItemPropertyValue -Path $RegistryPath -Name $PropertyName -ErrorAction SilentlyContinue }
    catch {
        $Error.RemoveAt(0)
        try { New-ItemProperty -Path $RegistryPath -Name $PropertyName -PropertyType $PropertyType }
        catch { $Error.RemoveAt(0) }
    }
    
    Set-ItemProperty -Path $RegistryPath -Name $PropertyName -Value $PropertyValue

    if ($null -eq (Get-ItemPropertyValue -Path $RegistryPath -Name $PropertyName -ErrorAction SilentlyContinue)) {
        Write-Host "Could not create the $(Join-Path $RegistryPath -ChildPath $PropertyName) registry." -ForegroundColor "Red"
    }
}

function Set-PowerPlan {
    # Timeout number in minutes; 0 = never

    Write-Host "Configuring power plan:" -ForegroundColor "Yellow"
    
    # Hibernate timeout
    powercfg -change "hibernate-timeout-ac" 0

    # Disk timeout
    powercfg -change "disk-timeout-ac" 0

    # Sleep timeout
    powercfg -change "standby-timeout-ac" 0

    # Screen timeout
    powercfg -change "monitor-timeout-ac" 10

    Write-Host "The power plan has been successfully updated." -ForegroundColor "Green"
}

function Set-ExplorerSettings {
    Write-Host "Configuring Explorer settings:" -ForegroundColor "Yellow"

    # Turn off Windows Narrator hotkey
    Edit-Registry -RegistryPath "HKCU:\SOFTWARE\Microsoft\Narrator\NoRoam" `
        -PropertyName "WinEnterLaunchEnabled" `
        -PropertyValue 0

    # Show file extensions
    Edit-Registry -RegistryPath "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -PropertyName "HideFileExt" `
        -PropertyValue 0

    # Show hidden files
    Edit-Registry -RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -PropertyName "Hidden" `
        -PropertyValue 1

    Write-Host "Explorer settings has been successfully updated." -ForegroundColor "Green"
}
