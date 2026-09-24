{ config, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system
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
