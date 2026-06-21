{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = [
    pkgs.nix-tree
    pkgs.nix-index
  ];

  system.stateVersion = "25.11"; # DON'T CHANGE THIS!
}
