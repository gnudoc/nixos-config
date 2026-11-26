# Root of Home Manager config - wired up in system/users.nix
# NixOS options are visible to every HM module below as osConfig.*
{ osConfig, ... }:
{
  imports = [
    ./apps
    ./cli
    ./desktop
    ./security
  ];

  # home.username and home.homeDirectory are filled in from users.users by
  # Home Manager's NixOS module. The state version follows the machine's.
  home.stateVersion = osConfig.system.stateVersion;
  home.sessionPath = [ "$HOME/.local/bin" ];

  # chromium/electron apps - use  wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # for gdb in emacs to work with libstdc++ pretty-printers from the nix store
  home.file.".gdbinit".text = ''
    add-auto-load-safe-path /nix/store
  '';

  # make fonts from home.packages visible to fontconfig
  fonts.fontconfig.enable = true;
}
