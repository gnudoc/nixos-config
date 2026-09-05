{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/boot.nix
    ../../common/system/networking.nix
    ../../common/system/desktop.nix
    ../../common/system/security.nix
    ../../common/system/nix.nix
    ../../common/system/core.nix
  ];

  networking.hostName = "galvorn";

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

}
