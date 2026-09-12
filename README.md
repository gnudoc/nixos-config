# NixOS Configuration

This repo contains a unified, declarative system config using [NixOS](https://nixos.org/) flakes and [Home Manager](https://github.com/nix-community/home-manager). I consider myself very new to nix and NixOS.

## Hosts

Currently, this flake provisions three machines:
* **`dwalin`**: Dell XPS 13 9300
* **`sure`**: Intel/Nvidia hybrid laptop configured with PRIME offloading
* **`galvorn`**: A StarLabs Starfighter laptop

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

I've started trying out age-nix for secrets such as wifi credentials, my .authinfo file, SSH config.
Adding more secrets involves:
* add a rule to `secrets/secrets.nix` eg "top_secret.age".publicKeys = [key1 key2];
* `nix run github:ryantm/agenix -- -e top_secret.age` - paste the config file to be secret-ised
* add something to configuration.nix eg `age.secrets.top_secret.file = ../../secrets/top_secret.age`
* ensure the bit of home manager config that would've configured the top_secret.conf now has `includes = ["/run/secrets/top_secret"]`
* done

## Backups & Storage

The systems utilize `btrfs` with subvolumes `@`, `@home`, `@nix`. Most of $HOME and specifically defined critical configs are automatically sync'd to a server via `rsync` using a systemd timer.

I wonder whether I should be using disko to declare the disk partitions and subvolumes?
