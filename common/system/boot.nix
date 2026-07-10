{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Workaround for Wayland resume freezes - systemd v256 exposed a bunch of kernel bugs
  systemd.services = {
    systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    systemd-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "5m";
  };

  # we probably want linux LTS (which is the default without this setting)
  # for servers esp if they use openZFS or any other out-of-tree things.
  boot.kernelPackages = pkgs.linuxPackages_latest;

}
