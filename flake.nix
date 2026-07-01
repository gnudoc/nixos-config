{
  description = "Unified flake for sure and dwalin";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # This pins afdko to 4.0.2, temp fix for cantarell-fonts not building w afdko 5
    nixpkgs-afdko.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # keeps system and h-m in line
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      home-manager,
      ...
    }@inputs:
    let
      mkSystem =
        {
          hostname,
          system ? "x86_64-linux",
          extraModules ? [ ],
          backupHost ? "ssh-nas-backup",
          tunnelAlias ? "ssh-nas-tunnel",
        }:
        let
          user = "nij";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          # Pass variables to everything to let them be referenced downstream
          specialArgs = {
            inherit
              inputs
              user
              backupHost
              tunnelAlias
              ;
          };
          modules = [
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
        dwalin = mkSystem {
          hostname = "dwalin";
          backupHost = "ssh-nas-backup";
          tunnelAlias = "my-proxy-tunnel";
          extraModules = [
            nixos-hardware.nixosModules.dell-xps-13-9300
          ];
        };
        sure = mkSystem {
          hostname = "sure";
          backupHost = "ssh-nas-backup";
          tunnelAlias = "my-proxy-tunnel";
          extraModules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
          ];
        };
      };
    };
}
