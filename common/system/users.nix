{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.user = lib.mkOption {
    type = lib.types.str;
    default = "nij";
    description = "A N Human";
  };

  config = {
    # The zsh configuration is in Home Manager (common/cli/zsh.nix), but zsh
    # also has to be enabled here to be accepted as a login shell.
    programs.zsh.enable = true;

    users.users.${config.my.user} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
        "cdrom"
        "lp"
      ];
    };

    home-manager = {
      # Use the system's pkgs (and with it nixpkgs.config.allowUnfree) rather
      # than evaluating a second, separately configured nixpkgs.
      useGlobalPkgs = true;
      # Install user packages to /etc/profiles/per-user instead of ~/.nix-profile.
      useUserPackages = true;
      users.${config.my.user} = ../home.nix;
    };
  };
}
