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

  # This lets libinput know that the laptop keyboard is internal, not external,
  # even though it's on a different bus from the trackpad, so that
  # "Disable-While-Typing" works
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Starfighter Keyboard]
    MatchUdevType=keyboard
    MatchName=AT Translated Set 2 keyboard
    AttrKeyboardIntegration=internal
  '';
}
