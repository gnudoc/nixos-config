{ pkgs, ... }:
{
  # CUPS, with HPLIP and its proprietary plugin (this printer needs the plugin)
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # mDNS, so the printer can be found on the network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # hp-setup and hp-testpage on PATH
  environment.systemPackages = [ pkgs.hplipWithPlugin ];
}
