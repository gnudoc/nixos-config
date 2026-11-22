{ ... }:

{
  imports = [
    ./apps
    ./cli
    ./desktop
    ./security
  ];
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  #for chromium/electron stuff in wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  #for gdb in emacs to work with libstdc++ pretty-printers from the nix store
  home.file.".gdbinit".text = ''
    add-auto-load-safe-path /nix/store
  '';

  fonts.fontconfig.enable = true;
}
