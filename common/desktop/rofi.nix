{ pkgs, ... }:

{
  home.packages = [ pkgs.rofi-power-menu ];

  programs.rofi = {
    enable = true;
    theme = "Monokai";
    extraConfig = {
      modi = "window,drun,ssh,keys,filebrowser,combi";
      "combi-modi" = "window,drun,ssh,keys,filebrowser";
      show = "combi";
    };
  };
}
