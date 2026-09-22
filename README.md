# NixOS Configuration

This repo contains a unified, declarative system config using [NixOS](https://nixos.org/) flakes and [Home Manager](https://github.com/nix-community/home-manager).

## Hosts
Currently, this flake provisions two machines:
* **`sure`**: Intel/Nvidia hybrid laptop configured with PRIME offloading
* **`galvorn`**: StarLabs Starfighter laptop

## Tech Stack & Environment
The environment is designed around a keyboard-driven Wayland workflow:
* **Window Manager**: Sway
* **Status Bar**: Waybar
* **Terminal**: Foot
* **Editor**: Emacs (pgtk/Wayland) + Vim as a fallback + nano as a fallback to the fallback!
* **Shell**: Zsh lightly customized with Starship and direnv
* **Launcher**: Rofi
* **Browsers**: Chromium
* **Theming**: Tokyo Night colour palette

## Repository Structure
* `flake.nix`: defines system inputs and maps host configs
* `hosts/`: Machine-specific configs, hardware layouts, and kernel module loading
* `common/`: Shared modules mapped across the systems
  * `apps/`: Major user-space applications (Emacs, browsers, terminal)
  * `cli/`: Shell environments, git, my scripts, and command-line utilities
  * `desktop/`: Sway, Waybar, GTK settings, Rofi, mako (notifications), wpaperd
  * `system/`: Core system functionality (bootloader, networking, security, Nix GC)
  * `security/`: GPG and SSH config
* `secrets/`: Age-encrypted secrets (Wifi, eduroam, SSH, authinfo)

## Secrets & Local Config

I'm using `agenix` for secrets such as wifi credentials, my .authinfo file, SSH config.
Adding or editing secrets involves:
* add a rule to `secrets/secrets.nix` eg "top_secret.age".publicKeys = [key1 key2];
* `nix run github:ryantm/agenix -- -e top_secret.age` - paste the config file to be secret-ised
* add something to configuration.nix eg `age.secrets.top_secret.file = ../../secrets/top_secret.age`
* ensure the bit of home manager config that would've configured the top_secret.conf now has `includes = ["/run/agenix/top_secret"]`
* done

## Backups & Storage

The systems utilize `btrfs` with subvolumes `@`, `@home`, `@nix`. Most of $HOME and specifically defined critical configs are automatically sync'd to a server via `rsync` using a systemd timer.

I wonder whether I should be using disko to declare the disk partitions and subvolumes?
