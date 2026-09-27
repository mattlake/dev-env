# Rebuild a Windows machine from this repo.
#
# NOT YET POPULATED. The windows/ tree currently holds only Windows Terminal
# settings; glazewm, zebar and flow-launcher configs still have to be captured
# from the Windows machine. This script links what exists and states plainly
# what is missing rather than pretending to be complete.
#
#   .\install\windows.ps1            # full run
#   .\install\windows.ps1 -DryRun    # print the plan, change nothing
#
# Symlinks on Windows need either Developer Mode enabled or an elevated shell.

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$LinksOnly
)

$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot
$BackupDir = Join-Path $HOME ".dev-env-backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Write-Info { param($Message) Write-Host "==> $Message" -ForegroundColor Blue }
function Write-Warn { param($Message) Write-Host " warn $Message" -ForegroundColor Yellow }

function New-ConfigLink {
    param(
        [Parameter(Mandatory)] [string]$Source,
        [Parameter(Mandatory)] [string]$Target
    )

    $src = Join-Path $Repo $Source

    if (-not (Test-Path $src)) {
        Write-Warn "missing in repo, skipping: $Source"
        return
    }

    $existing = Get-Item $Target -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $src) {
        Write-Host "      ok: $Target"
        return
    }

    if ($existing) {
        if ($DryRun) {
            Write-Host "      would back up: $Target"
        }
        else {
            $rel = $Target.Replace("$HOME\", '')
            $dest = Join-Path $BackupDir $rel
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
            Move-Item -Path $Target -Destination $dest
            Write-Warn "backed up existing $Target to $BackupDir"
        }
    }

    if ($DryRun) {
        Write-Host "      would link: $Target -> $Source"
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    New-Item -ItemType SymbolicLink -Path $Target -Target $src -Force | Out-Null
    Write-Host "      linked: $Target -> $Source"
}

if (-not $LinksOnly) {
    Write-Info 'Packages'
    Write-Warn 'no winget/scoop manifest yet -- add one when capturing this machine'
}

Write-Info 'Symlinks: shared'
New-ConfigLink 'shared\nvim'                 (Join-Path $env:LOCALAPPDATA 'nvim')
New-ConfigLink 'shared\wezterm\.wezterm.lua' (Join-Path $HOME '.wezterm.lua')
New-ConfigLink 'shared\jetbrains\.ideavimrc' (Join-Path $HOME '.ideavimrc')

Write-Info 'Symlinks: Windows'
$wtDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
if (Test-Path $wtDir) {
    New-ConfigLink 'windows\windows-terminal\settings.json' (Join-Path $wtDir 'settings.json')
}
else {
    Write-Warn 'Windows Terminal not installed, skipping its settings'
}

Write-Host @'

Done, as far as this script goes. Still to capture from this machine:

  * glazewm       ~/.glaze-wm/config.yaml  -> windows/glazewm/
  * zebar         ~/.glzr/zebar/           -> windows/zebar/
  * flow launcher %APPDATA%\FlowLauncher\  -> windows/flow-launcher/
  * herdr         %APPDATA%\herdr\config.toml -> shared/herdr/
  * a winget or scoop manifest to match macos/Brewfile

WSL shares the shared/ tree: run install/macos.sh --links from inside WSL,
or symlink shared/zsh/.zshrc to ~/.zshrc there by hand.
'@
