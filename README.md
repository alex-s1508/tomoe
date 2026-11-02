<p align="center">
  <img src="dotfiles/assets/images/tomoe-header.png" width="760" alt="Chie Satonaka">
</p>
<h3 align="center">T O M O E &ensp;巴</h3>

<p align="center"><strong>CachyOS</strong></p>
<p align="center"><em>Umbriel + Noctalia</em></p>
<p align="center"><em>Monochrome Chie Satonaka — Persona 4</em></p>

# How to install

```sh
git clone https://github.com/alex-s1508/tomoe.git
cd tomoe
./tomoe install
```

Installs Umbriel + Noctalia (greeter); other setup files are in `dotfiles/`. Configures greetd; backups and logs in `~/.local/state/tomoe/`.

## Main keybinds

| Keybind | Action |
|---|---|
| `Mod+Return` | Terminal (kitty) |
| `Mod+B` | Browser |
| `Mod+E` | Files (Nautilus) |
| `Mod+N` | VSCode |
| `Mod+Space` | Launcher |
| `Mod+S` / `Mod+Ctrl+S` | Scratchpad / send window |
| `Mod+Shift+S` | Screenshot |
| `Mod+Tab` | Overview |
| `Mod+F` | Maximize |

## Commands

```sh
./tomoe install [--dry-run] [--yes] [--reboot]
./tomoe update [--all|--umbriel|--noctalia|--fastfetch|--chrome|--greetd|--monitors]
./tomoe hidden-apps [--list|--show|--hide]
```

## Screenshots

<p align="center">
  <img src="dotfiles/assets/images/tomoe-screenshot.png" width="760" alt="Tomoe desktop">
</p>
