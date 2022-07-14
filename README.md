# E-RELevant's dotfiles for Windows

PowerShell files for Windows, including common application installations through `winget`, as well as developer-friendly Windows configuration defaults.

> **Note:** Windows Package Manager `winget` command-line tool is bundled with Windows 11 and modern versions of Windows 10 by default as the App Installer. [Read more](https://docs.microsoft.com/en-us/windows/package-manager/winget/)

## Installation

Open any Windows PowerShell host console with administrator rights, and run:

```posh
$GitHubRepositoryAuthor = "E-RELevant"; `
$GitHubRepositoryName = "dotfiles-windows"; `
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; `
Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$($GitHubRepositoryAuthor)/$($GitHubRepositoryName)/main/Download.ps1");
```

The `Download.ps1` script will copy the files to your `$HOME\.dotfiles` directory.

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force` from a PowerShell running as Administrator.

## Configuration

First, a `config.json` is created containing the selected settings. Then, it will execute according to them, giving you time to do anything else.

### Options

- [7-Zip](https://www.7-zip.org/download.html)
  - Installation
- [Git](https://git-scm.com/downloads)
  - Installation
  - Configuration
- [Nerd Font](https://www.nerdfonts.com/)
  - Installation
  - Configuration for Windows Terminal
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?#install-powershell-using-winget)
  - PowerShell Core installation
  - `$PROFILE` configuration
  - Modules installation
    - [posh-git](https://github.com/dahlbyk/posh-git)
    - [PSWebSearch](https://github.com/JMOrbegoso/PSWebSearch)
    - [PSReadLine](https://github.com/PowerShell/PSReadLine)
    - [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
    - [z](https://www.powershellgallery.com/packages/z)
  - [Oh My Posh](https://ohmyposh.dev/docs)
    - Installation
    - Using `capr4n` theme
- [PowerToys](https://docs.microsoft.com/en-us/windows/powertoys/install#install-with-windows-package-manager)
  - Installation
- Windows
  - Dark mode
  - Explorer configuration
  - Power plan settings configuration
  - Rename Computer
- [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal)
  - Installation (winget, msstore)
  - Settings configuration: custom actions, defaults.
- [Visual Studio Code](https://code.visualstudio.com/)
  - Installation
  - Extensions installation
  - Settings configuration
- 'Workspace' directory configuration

## Feedback

Suggestions/improvements are
[welcome and encouraged](https://github.com/E-RELevant/dotfiles-windows/issues).
