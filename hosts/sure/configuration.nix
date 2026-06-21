{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/boot.nix # bootloader, hibernating, which kernel
    ../../common/system/networking.nix # networkmanager, dnsutils
    ../../common/system/desktop.nix # Sway, XDG portals, pipewire, bluetooth
    ../../common/system/security.nix # PAM, Polkit, sudo rule for laptop backup
    ../../common/system/nix.nix # GC, experimental features, nix tools
    ../../common/system/core.nix
  ];

  # Declaratively ensure the mount point exists with the correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/internal-ssd 0755 nij users -"
  ];

  networking.hostName = "sure";

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  ### --- CHANGE ON A NEW SYSTEM --- ###
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
