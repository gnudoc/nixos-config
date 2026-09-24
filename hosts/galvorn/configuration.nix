{ config, hostname, ... }:
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

  networking.hostName = hostname;

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  age.secrets.tailscale.file = ../../secrets/tailscale.age;

  services.tailscale = {
    authKeyFile = config.age.secrets.tailscale.path;
    extraUpFlags = [
      "--exit-node=100.84.16.46"
      "--exit-node-allow-lan-access=true"
      "--operator=nij"
    ];
  };
}
