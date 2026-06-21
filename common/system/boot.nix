{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "5m";
  };

  # we probably want linux LTS (which is the default without this setting)
  # for servers esp if they use openZFS or any other out-of-tree things.
  boot.kernelPackages = pkgs.linuxPackages_latest;

}
