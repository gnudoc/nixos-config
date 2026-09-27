{ hostname, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system
  ];

  # Declaratively ensure the mount point exists with the correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/internal-ssd 0755 ${user} users -"
  ];

  networking.hostName = hostname;

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
