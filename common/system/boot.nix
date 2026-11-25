{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Hibernation resumes from the swap partition that hardware-configuration.nix
  # already declares, so read the device from there instead of repeating a UUID.
  boot.resumeDevice = lib.mkIf (config.swapDevices != [ ]) (lib.head config.swapDevices).device;

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
  # By making the _latest kernel `mkDefault`, we allow them to get
  # linuxPackages, without having to do mkForce.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

}
