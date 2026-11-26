# Sway session, keyboard layout, audio, bluetooth, fonts
{ pkgs, ... }:
{
  # Installs sway and what a bare compositor needs: polkit, the swaylock
  # PAM service, xdg-desktop-portal (wlr + gtk), dconf, XWayland, and
  # hardware.graphics. The sway *config* is in common/desktop/sway.nix.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Also used by the tty (console.useXkbConfig in core.nix) and by sway
  # (common/desktop/sway.nix reads it back through osConfig).
  services.xserver.xkb = {
    layout = "gb";
    variant = "dvorak";
    options = "ctrl:swapcaps";
  };
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true; # lets pipewire ask for realtime scheduling
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.cantarell-fonts
    pkgs.noto-fonts
  ];
}
