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
