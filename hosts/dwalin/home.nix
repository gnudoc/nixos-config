{ pkgs, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # programs.git.signing.key = "<ID>"; # now in ~/.config/git/config.local

  # Blu-ray keys
  # home.file.".config/aacs/KEYDB.cfg".source = pkgs.fetchurl {
  #   url = "http://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg";
  #   hash = "sha256-AdDOJ4CFMm4FPDhfuA3gYAbi2zcySVNUwIi9VWO34l8=";
  # };
}
