{ hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system
  ];

  # Declaratively ensure the mount point exists with the correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/internal-ssd 0755 nij users -"
  ];

  networking.hostName = hostname;

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

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
