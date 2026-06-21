# NixOS Configuration

This repo contains a unified, declarative system config using [NixOS](https://nixos.org/) flakes and [Home Manager](https://github.com/nix-community/home-manager). I consider myself very new to nix and NixOS.

## Hosts

Currently, this flake provisions two machines:
* **`dwalin`**: Dell XPS 13 9300
* **`sure`**: Intel/Nvidia hybrid laptop configured with PRIME offloading

## Tech Stack & Environment

The environment is designed around a keyboard-driven Wayland workflow:

* **Window Manager**: Sway
* **Status Bar**: Waybar
* **Terminal**: Foot
* **Editor**: Emacs (pgtk/Wayland) + Vim as a fallback + nano as a fallback to the fallback!
* **Shell**: Zsh lightly customized with Starship and direnv
* **Launcher**: Rofi
* **Browsers**: Chromium & Brave
* **Theming**: Tokyo Night colour palette

## Repository Structure

* `flake.nix`: defines inputs (which you might think of in traditional distros as package channels or repos - NixOS unstable, NixOS hardware) and host outputs
* `hosts/`: Machine-specific configs, hardware layouts, and kernel module loading
* `common/`: Shared modules mapped across the systems
  * `apps/`: Major user-space applications (Emacs, browsers, terminal)
  * `cli/`: Shell environments, git, my rsync-based backup system, and command-line utilities
  * `desktop/`: Sway, Waybar, GTK settings, and Rofi
  * `system/`: Core system functionality (bootloader, networking, security, Nix garbage collection)
  * `security/`: GPG and SSH config

## Secrets & Local Config

To maintain a secure public repo, sensitive infrastructure details (e.g. SSH endpoints and keys) are excluded from tracking. These are loaded locally via Git and SSH includes:
* `~/.ssh/config.local`
* `~/.config/git/config.local`
Maybe I should be using sops-nix or age-nix for these secrets, but those felt like a bit of overkill. I may yet do so.

## Backups & Storage

The systems utilize `btrfs` with subvolumes `@`, `@home`, `@nix`. Most of $HOME and specifically defined critical configs are automatically sync'd to a server via `rsync` using a systemd timer.
