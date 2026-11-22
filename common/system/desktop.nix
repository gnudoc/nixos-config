# WM stuff, audio stuff
{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.xserver.xkb = {
    layout = "gb";
    variant = "dvorak";
    options = "ctrl:swapcaps";
  };
  hardware.bluetooth.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  security.rtkit.enable = true; # RealTimeKit; relates to pipewire etc
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # System-wide fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.cantarell-fonts
    pkgs.noto-fonts
  ];
}
