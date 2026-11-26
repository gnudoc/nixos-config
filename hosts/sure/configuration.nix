# sure: Intel/Nvidia hybrid laptop, PRIME offloading
{ config, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
  ];

  system.stateVersion = "25.11"; # DON'T CHANGE THIS!

  # off until secrets/sure_backup_key.age exists, which in turn needs
  # this machine's host key in secrets/secrets.nix
  # my.backup.enable = true;

  # hardware-configuration.nix mounts the second SSD here; this hands the root
  # of that filesystem to the user.
  systemd.tmpfiles.rules = [
    "d /mnt/internal-ssd 0755 ${config.my.user} users -"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
