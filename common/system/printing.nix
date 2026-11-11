{ pkgs, ... }:
{
  # 1. Enable CUPS and load HPLIP with the proprietary binary plugin
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # 2. Enable Avahi/mDNS (required for P1102w over Wi-Fi)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # 3. Expose hp-setup and hp-testpage in our terminal PATH
  environment.systemPackages = with pkgs; [
    hplipWithPlugin
  ];
}
