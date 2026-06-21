{ pkgs, user, ... }:

let
  backupPrepare = pkgs.callPackage ../cli/backup-prepare.nix { };
in
{
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "ter-v18b";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  hardware.enableRedistributableFirmware = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # The zsh config is in home manager, but
  # we enable it here so it's available for /etc/shells
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "cdrom"
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = [
    # Utils/Editors
    pkgs.wget
    pkgs.nano
    pkgs.file

    # Archives & Text
    pkgs.unzip
    pkgs.zip
    pkgs.jq
    pkgs.tree

    # Hardware & System Admin
    pkgs.pciutils
    pkgs.usbutils
    pkgs.lshw
    pkgs.lm_sensors
    pkgs.psmisc
    pkgs.lsof
    pkgs.btop

    # The preparatory script for the backup system
    backupPrepare
  ];

  services.fstrim.enable = true;

}
