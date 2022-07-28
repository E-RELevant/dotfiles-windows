########################################################################
#                           Initial Commands                           #
########################################################################

Clear-Host

########################################################################
#                            Import Modules                            #
########################################################################

Import-Module "posh-git"
Import-Module "Terminal-Icons"
Import-Module "PSReadLine"

########################################################################
#                            System Aliases                            #
########################################################################

function Get-CommandPath() {
  Param (
    [String]$CommandName
  )

  $command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue
  if (($null -ne $command) -and ($command.CommandType -eq "alias")) {
    $command = Get-Command -Name (Get-Alias $command).Definition -ErrorAction SilentlyContinue
  }
    
  if ($null -ne $command) {
    $command | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
  }
  else {
    Write-Host "Could not locate the source of '$($CommandName)'."
  }
}
Set-Alias -Name "locate" -Value "Get-CommandPath"

function Connect-RemoteDesktop() {
  Param (
    [String]$server
  )

  Start-Process mstsc -ArgumentList "/v:$server"
}
Set-Alias -Name "rdp" -Value "Connect-RemoteDesktop"

function Get-Uptime {
  Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object CSName, LastBootUpTime
}
Set-Alias -Name "uptime" -Value "Get-Uptime"

########################################################################
#                          Directories Aliases                         #
########################################################################

function Edit-Hosts() { Invoke-Expression "$(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $($HostsFullPath = Join-Path $env:windir -ChildPath "system32" | Join-Path -ChildPath "drivers" | Join-Path -ChildPath "etc" | Join-Path -ChildPath "hosts")" }
Set-Alias -Name "hosts" -Value "Edit-Hosts"
function Edit-Profile() { Invoke-Expression "$(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $profile" }
Set-Alias -Name "profile" -Value "Edit-Profile"

function Open-RecycleBin() { explorer.exe Shell:RecycleBinFolder }
Set-Alias -Name "trash" -Value "Open-RecycleBin"

function Invoke-AsAdmin() {
  if ($args.Length -eq 1) {
    start-process $args[0] -verb "runAs"
  }
  if ($args.Length -gt 1) {
    start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
  }
}
Set-Alias -Name "sudo" -Value "Invoke-AsAdmin"

function CreateAndSet-Directory([String] $path) { New-Item $path -ItemType Directory -ErrorAction SilentlyContinue Set-Location $path }
Set-Alias -Name "mkcd" -Value "CreateAndSet-Directory"

function Find-FileInDirectoryRecursive($name) {
  Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Host "${place_path}\${_}"
  }
}
Set-Alias -Name "find" -Value "Find-FileInDirectoryRecursive"

function Expand-ZipFile ($file) {
  $dirname = (Get-Item $file).Basename
  Write-Host "Extracting $file to $dirname"
  New-Item -Force -ItemType directory -Path $dirname
  Expand-Archive $file -OutputPath $dirname -ShowProgress
}

########################################################################
#                             Navigation                               #
########################################################################

function goto() {
  Param (
    $location
  )

  Switch ($location) {
    "dl" {
      Set-Location -Path (Join-Path $HOME -ChildPath "Downloads")
    }
    "doc" {
      Set-Location -Path (Join-Path $HOME -ChildPath "Documents")
    }
    "home" {
      Set-Location -Path "$HOME"
    }
    default {
      try {
        Set-Location -Path $location
      }
      catch {
        Write-Host "Invalid location"
      }  
    }
  }
}
New-Alias -Name "g" -Value "goto"

${function:~} = { Set-Location ~ }

# PowerShell might not allow ${function:..} because of an invalid path error
${function:Set-ParentLocation} = { Set-Location .. }
Set-Alias -Name ".." -Value "Set-ParentLocation"

${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }

########################################################################
#                              Git Aliases                             #
########################################################################

function Invoke-GitSuperClone() {
  Param ($repositoryName)
  $DirectoryName = $repositoryName.Split("/")[-1].Replace(".git", "")
  & git clone $repositoryName $DirectoryName | Out-Null
  Set-Location $DirectoryName
  git submodule init
  git submodule update
}
Set-Alias -Name "gsc" -Value "Invoke-GitSuperClone"

function Invoke-GitCheckoutBranch() {
  Param ($branchName)

  git checkout -b $branchName
}
Set-Alias -Name "gcb" -Value "Invoke-GitCheckoutBranch"

function Invoke-GitAdd() {
  Param ($fileToAdd)

  git add $fileToAdd
}
Set-Alias -Name "ga" -Value "Invoke-GitAdd"

function Invoke-GitAddAll() {
  git add --all
}
Set-Alias -Name "gaa" -Value "Invoke-GitAddAll"

function Invoke-GitStatus() {
  git status
}
Set-Alias -Name "gst" -Value "Invoke-GitStatus"

function Invoke-GitCommitMessage() {
  Param ($message)

  git commit -m $message
}
Set-Alias -Name "gcmsg" -Value "Invoke-GitCommitMessage"

function Invoke-GitPushOriginCurrentBranch() {
  git push origin HEAD
}
Set-Alias -Name "ggp" -Value "Invoke-GitPushOriginCurrentBranch"

function Invoke-GitLogStat() {
  git log --stat
}
Set-Alias -Name "glg" -Value "Invoke-GitLogStat"

function Invoke-GitSoftResetLastCommit() {
  git reset --soft HEAD^1
}
Set-Alias -Name "gsrlc" -Value "Invoke-GitSoftResetLastCommit"

function Invoke-GitHardResetLastCommit() {
  git reset --hard HEAD~1
}
Set-Alias -Name "ghrlc" -Value "Invoke-GitHardResetLastCommit"

########################################################################
#                            Docker Aliases                            #
########################################################################

function Invoke-DockerPull() {
  docker pull
}
Set-Alias -Name "dpl" -Value "Invoke-DockerPull"

function Invoke-DockerListWorkingContainers() {
  docker container ls
}
Set-Alias -Name "dlc" -Value "Invoke-DockerListWorkingContainers"

function Invoke-DockerListContainers() {
  docker container ls -a
}
Set-Alias -Name "dlca" -Value "Invoke-DockerListContainers"

function Invoke-DockerImages() {
  docker images
}
Set-Alias -Name "dli" -Value "Invoke-DockerImages"

function Invoke-DockerStopContainer() {
  docker container stop
}
Set-Alias -Name "dsc" -Value "Invoke-DockerStopContainer"

function Invoke-DockerDeleteContainer() {
  docker container rm
}
Set-Alias -Name "drc" -Value "Invoke-DockerDeleteContainer"

function Invoke-DockerDeleteImage() {
  docker image rm
}
Set-Alias -Name "dri" -Value "Invoke-DockerDeleteImage"

New-Alias -Name "k" -Value "kubectl"


########################################################################
#                              PSReadLine                              #
########################################################################

# Prediction functions
Set-PSReadLineOption -PredictionSource "History"
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -PredictionViewStyle "ListView"
Set-PSReadLineOption -Colors @{ "InlinePrediction" = [ConsoleColor]::DarkGray }

# Attempt to perform completion on the text surrounding the cursor.
Set-PSReadLineKeyHandler -Key "Tab" -Function "Complete"

# Start interactive screen capture - up/down arrows select lines,
# enter copies selected text to clipboard as text and HTML.
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function "CaptureScreen"

# Token based word movement
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

# Shows the entire or filtered history using Out-GridView.
Set-PSReadLineKeyHandler -Key "F7" `
  -BriefDescription "History" `
  -LongDescription "Show command history" `
  -ScriptBlock {
  $pattern = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
  if ($pattern) {
    $pattern = [regex]::Escape($pattern)
  }

  $history = [System.Collections.ArrayList]@(
    $last = ''
    $lines = ''
    foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
      if ($line.EndsWith('`')) {
        $line = $line.Substring(0, $line.Length - 1)
        $lines = if ($lines) {
          "$lines`n$line"
        }
        else {
          $line
        }
        continue
      }

      if ($lines) {
        $line = "$lines`n$line"
        $lines = ''
      }

      if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
        $last = $line
        $line
      }
    }
  )
  $history.Reverse()

  $command = $history | Out-GridView -Title History -PassThru
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
  }
}

# Enter matching quotes
Set-PSReadLineKeyHandler -Key "Alt+(", "Alt+{", "Alt+[" `
  -BriefDescription "InsertPairedBraces" `
  -LongDescription "Insert matching braces" `
  -ScriptBlock {
  param($key, $arg)

  $closeChar = switch ($key.KeyChar) {
    <#case#> '(' { [char]')'; break }
    <#case#> '{' { [char]'}'; break }
    <#case#> '[' { [char]']'; break }
  }

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
  if ($selectionStart -ne -1) {
    # Text is selected, wrap it in brackets
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    # No text is selected, wrap entire line
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $key.KeyChar + $line + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  }
}

########################################################################
#                              Oh My Posh                              #
########################################################################

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/capr4n.omp.json' | Invoke-Expression