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

  # Declaratively ensure the mount point exists with the correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/internal-ssd 0755 ${config.my.user} users -"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/e7336446-3fa2-44d3-b5af-e2d2a2277920"; # swap partition

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
