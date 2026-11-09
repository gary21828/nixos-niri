# NixOS Niri Desktop

NixOS configuration for a [Niri](https://github.com/YaLTeR/niri) Wayland compositor desktop, managed with flakes and Home Manager.

Catppuccin Mocha–inspired theme across Niri, Waybar, Alacritty, and the lock screen.

## Files

| File | Purpose |
|------|---------|
| `flake.nix` | Flake entry point (nixpkgs 26.05, home-manager, unstable) |
| `configuration.nix` | System config: Niri, greetd, PipeWire, fonts, user services |
| `home.nix` | User config: Waybar, Niri keybinds, Alacritty, swaylock, wlsunset, browsers |

## Features

- **Niri** scrollable tiling compositor with Catppuccin focus ring and shadows
- **Waybar** with niri workspaces, temperature, battery, and system stats
- **Alacritty** with Maple Mono NF CN, 70% opacity, and a distinct yellow border
- **swaylock** themed lock screen (clock + indicator)
- **wlsunset** night light (17:30–07:30, 3200K)
- **Maple Mono** fonts (truetype, NF, NF-CN)
- zram swap, weekly GC, Flatpak, fcitx5 Chinese input

## Requirements

- NixOS 26.05 (or compatible)
- UEFI system
- Generate `hardware-configuration.nix` on the target machine

## Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/gary21828/nixos-niri.git ~/nixos-dotfiles
   cd ~/nixos-dotfiles
   ```

2. Generate hardware config (if needed):
   ```bash
   sudo nixos-generate-config --root / --dir .
   ```

3. Adjust hostname/username in `flake.nix` if desired (defaults: `nixos` / `gary`).

4. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

## Useful aliases

Defined in `home.nix`:

- `update` — update flake inputs and rebuild
- `rebuild` — rebuild without updating inputs
- `cleanup` — garbage collect
- `optimise` — optimise the Nix store

## Keybindings (Niri)

| Key | Action |
|-----|--------|
| `Mod+T` | Alacritty |
| `Mod+D` | Fuzzel launcher |
| `Mod+B` | Firefox |
| `Super+Alt+L` | Lock screen |
| `Mod+Q` | Close window |
| `Mod+1`–`9` | Switch workspace |

## License

MIT
