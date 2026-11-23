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
    { nixpkgs, ... }@inputs:
    let
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          # specialArgs is only for what modules need inside `imports`, which is
          # resolved before any option exists. Everything else travels as
          # options: see my.user (common/system/users.nix) and my.backup.
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            { networking.hostName = hostname; }
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs [ "galvorn" "sure" ] mkHost;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
