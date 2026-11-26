# Everything every host has in common ot the NixOS level.
# The Home Manager half of the configurationn starts at ../home.nix
{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ./backup.nix
    ./boot.nix
    ./core.nix
    ./desktop.nix
    ./networking.nix
    ./nix.nix
    ./printing.nix
    ./security.nix
    ./users.nix
  ];
}
