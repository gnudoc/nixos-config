{
  description = "Unified flake for sure and galvorn";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # `follows` makes each input build against the above nixpkgs instead
    # of locking its own separate version
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      home-manager,
      agenix,
      ...
    }@inputs:
    let
      mkSystem =
        {
          hostname,
          extraModules ? [ ],
          backupHost ? "girion-tailscale",
        }:
        nixpkgs.lib.nixosSystem {
          # Pass variables to everything to let them be referenced downstream
          specialArgs = {
            inherit
              inputs
              backupHost
              ;
          };
          modules = [
            agenix.nixosModules.default
            ./hosts/${hostname}/configuration.nix
            { networking.hostName = hostname; }
            home-manager.nixosModules.home-manager
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        sure = mkSystem {
          hostname = "sure";
          backupHost = "girion-tailscale";
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
          ];
        };
        galvorn = mkSystem {
          hostname = "galvorn";
          backupHost = "girion-tailscale";
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
          ];
        };
      };
    };
}
