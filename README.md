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
* `flake.nix`: the inputs, and one NixOS system per directory under `hosts/`
* `hosts/<name>`: what is specific to one machine: hardware, state version, per-host services
* `common/system/`: NixOS modules shared by every host (boot, networking, users, backup, Nix settings)
* `common/home.nix`: root of the Home Manager config, which is the rest of `common/`:
  * `apps/`: Major user-space applications (Emacs, browsers, terminal)
  * `cli/`: Shell environments, git, and command-line utilities
  * `desktop/`: Sway, Waybar, GTK settings, Rofi, mako (notifications), wpaperd
  * `security/`: GPG and SSH config
* `secrets/`: Age-encrypted secrets (Wifi, eduroam, SSH, authinfo)

Values that more than one module needs are declared as options rather than passed around as function arguments: `my.user` (`common/system/users.nix`) and `my.backup.*` (`common/system/backup.nix`). Home Manager modules read NixOS options through `osConfig`.

`nix fmt` formats the whole repo.

## Secrets & Local Config

I'm using `agenix` for secrets such as wifi credentials, my .authinfo file, SSH config.
Adding or editing secrets involves:
* add a rule to `secrets/secrets.nix` eg "top_secret.age".publicKeys = [key1 key2];
* `cd secrets && agenix -e top_secret.age` - paste the config file to be secret-ised
* declare it in the module that uses it eg `age.secrets.top_secret.file = ../../secrets/top_secret.age`
* refer to the decrypted file by option, never by typing `/run/agenix/...`: `config.age.secrets.top_secret.path` in a NixOS module, `osConfig.age.secrets.top_secret.path` in a Home Manager one
* done

A new machine needs its host key (`/etc/ssh/ssh_host_ed25519_key.pub`) added to `secrets/secrets.nix`, followed by `agenix --rekey`, before it can decrypt anything.

## Backups & Storage

The systems utilize `btrfs` with subvolumes `@`, `@home`, `@nix`. Most of $HOME and specifically defined critical configs are automatically sync'd to a server via `rsync` using a systemd timer, on hosts that set `my.backup.enable = true`.

I wonder whether I should be using disko to declare the disk partitions and subvolumes?
