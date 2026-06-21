# WM stuff, audio stuff
{ pkgs, ... }:

{
  systemd.tmpfiles.rules = [ "d /var/lib/alsa 0755 root root -" ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.xserver.xkb = {
    layout = "gb";
    variant = "dvorak";
    options = "ctrl:swapcaps";
  };
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
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
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    cantarell-fonts
    noto-fonts
  ];

}
