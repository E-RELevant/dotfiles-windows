function Set-WorkspaceDisk() {
    $ValidDisks = Get-PSDrive -PSProvider "FileSystem" | Select-Object -ExpandProperty "Root"
    do {
        Write-Host "Choose the location of your development workspace:" -ForegroundColor "Yellow"
        Write-Host $ValidDisks -ForegroundColor "Yellow"
        $WorkspaceDisk = Read-Host -Prompt "Please choose one of the available disks"
    }
    while (-not ($ValidDisks -Contains $WorkspaceDisk.ToUpper()))

    return $WorkspaceDisk
}
function Set-WorkspaceDirectory() {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [String]
        $WorkspaceDisk
    )

    $WorkspaceDirectory = Join-Path -Path $WorkspaceDisk -ChildPath "Workspace"

    if (-not (Test-Path $WorkspaceDirectory)) {
      Write-Host "Creating your development workspace directory:" -ForegroundColor "Yellow" -NoNewline
      New-Item $WorkspaceDirectory -ItemType directory
      if (-not (Test-Path $WorkspaceDirectory)) {
        Write-Host "Could not create the 'Workspace' directory" -ForegroundColor "Red"
      }
      else {
        Write-Host "The 'Workspace' directory has been created successfully." -ForegroundColor "Green"
      }
    }
    else {
      Write-Host "The 'Workspace' directory exists already, skipping." -ForegroundColor "Yellow"
    }
}