{ pkgs, ... }:

{
  home.packages = [ pkgs.rofi-power-menu ];

  programs.rofi = {
    enable = true;
    theme = "Monokai";
    settings = {
      modes = "window,drun,ssh,keys,filebrowser,combi";
      combi-modes = "window,drun,ssh,keys,filebrowser";
      show = "combi";
    };
  };
}
