{ user, ... }:

{
  imports = [
    ./apps
    ./cli
    ./desktop
    ./security
  ];
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  #for chromium/electron stuff in wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
