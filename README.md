# dev-env

Portable configuration shared between a Windows machine (with WSL) and a Mac.
Tracked so either can be rebuilt from scratch, and so the setup can be handed
to someone else.

## Layout

```
shared/     Same on every machine
  zsh/        .zshrc
  nvim/       Neovim, with lazy-lock.json pinned
  wezterm/    .wezterm.lua
  jetbrains/  .ideavimrc
macos/      Mac only
  aerospace/  tiling window manager
  sketchybar/ status bar
  Brewfile    package manifest
windows/    Windows only
  windows-terminal/
install/
  macos.sh    rebuild a Mac
  windows.ps1 rebuild a Windows machine
```

## Installing

Mac:

```sh
git clone git@github.com:mattlake/dev-env.git ~/dev-env
~/dev-env/install/macos.sh --dry-run   # inspect the plan first
~/dev-env/install/macos.sh
```

Windows, from an elevated shell or with Developer Mode on:

```powershell
git clone git@github.com:mattlake/dev-env.git $HOME\dev-env
.\dev-env\install\windows.ps1 -DryRun
.\dev-env\install\windows.ps1
```

Both installers are idempotent. Anything already at a target path is moved to
`~/.dev-env-backup/<timestamp>/` before a symlink replaces it, so nothing is
overwritten in place. `--links` / `-LinksOnly` skips package installation.

## Machine-local overrides

Anything machine-specific or private stays out of this repo. Each is optional
and gitignored:

| File | Purpose |
| --- | --- |
| `~/.zshrc.local` | sourced at the end of `.zshrc` |
| `~/.wezterm.local.lua` | see `shared/wezterm/.wezterm.local.lua.example` |

## Window management

The Mac setup mirrors the Windows one:

| Windows | macOS |
| --- | --- |
| GlazeWM | AeroSpace |
| Zebar | SketchyBar |
| Flow Launcher | Raycast |

Raycast keeps its settings in its own cloud sync rather than in dotfiles, so it
cannot be fully captured here. Sign in to restore extensions and hotkeys.

## Known gaps

- `windows/` holds only Windows Terminal settings. GlazeWM, Zebar and Flow
  Launcher configs still need capturing from that machine, along with a
  winget or scoop manifest to match `macos/Brewfile`.
- `install/windows.ps1` has never been executed. It was written on the Mac,
  where there is no PowerShell to even parse it.
- AeroSpace never triggers SketchyBar's `aerospace_workspace_change` event:
  `sketchybarrc` subscribes to it but `aerospace.toml` has no
  `exec-on-workspace-change`, so workspace indicators do not update. The bar
  also has no `start-at-login`.
- `borders` (JankyBorders) is installed and in the Brewfile but nothing
  launches it and it has no config.
- `herdr` is not set up on the Mac yet. Its config is
  `~/.config/herdr/config.toml` (`%APPDATA%\herdr\config.toml` on Windows) and
  holds no secrets, so it belongs in `shared/` once written.
- `.zshrc` aliases `lzd` to `lazydocker` and `pwgen` to itself, neither of
  which is installed on the Mac.
