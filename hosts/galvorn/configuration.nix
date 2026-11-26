# galvorn: StarLabs StarFighter
{
  config,
  inputs,
  lib,
  ...
}:
let
  tailscaleFlags = [
    "--exit-node=100.84.16.46"
    "--exit-node-allow-lan-access=true"
    "--operator=${config.my.user}"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
  ];

  system.stateVersion = "25.11"; # DON'T CHANGE THIS!

  my.backup.enable = true;

  # hardware-configuration.nix recorded /boot as world-readable
  # which bootctl reports as a security hole because systemd-boot keeps its
  # random seed there. mkForce replaces that list rather than adding to it.
  fileSystems."/boot".options = lib.mkForce [
    "fmask=0077"
    "dmask=0077"
  ];

  age.secrets.tailscale.file = ../../secrets/tailscale.age;

  services.tailscale = {
    authKeyFile = config.age.secrets.tailscale.path;
    # extraUpFlags are only used when the machine (re)authenticates;
    # extraSetFlags are applied every time tailscaled starts.
    extraUpFlags = tailscaleFlags;
    extraSetFlags = tailscaleFlags;
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
