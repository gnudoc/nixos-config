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

  # Newest kernel, for the laptops' recent hardware. mkDefault so that a host
  # with an out-of-tree module that lags behind new kernels (nvidia, ZFS) can
  # choose pkgs.linuxPackages without needing mkForce.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Hibernation resumes from the swap partition that hardware-configuration.nix
  # already declares, so read the device from there instead of repeating a UUID.
  boot.resumeDevice = lib.mkIf (config.swapDevices != [ ]) (lib.head config.swapDevices).device;

  # Closing the lid suspends; after 5min asleep the machine hibernates.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep.HibernateDelaySec = "5m";
}
