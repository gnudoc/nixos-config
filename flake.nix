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
          tunnelAlias ? "ssh-nas-tunnel",
        }:
        let
          user = "nij";
        in
        nixpkgs.lib.nixosSystem {
          # Pass variables to everything to let them be referenced downstream
          specialArgs = {
            inherit
              inputs
              user
              backupHost
              tunnelAlias
              hostname
              ;
          };
          modules = [
            agenix.nixosModules.default
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  user
                  backupHost
                  tunnelAlias
                  hostname
                  ;
              };
              home-manager.users.${user} = import ./hosts/${hostname}/home.nix;
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        sure = mkSystem {
          hostname = "sure";
          backupHost = "girion-tailscale";
          tunnelAlias = "ssh-nas-tunnel";
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
          ];
        };
        galvorn = mkSystem {
          hostname = "galvorn";
          backupHost = "girion-tailscale";
          tunnelAlias = "ssh-nas-tunnel";
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
          ];
        };
      };
    };
}
