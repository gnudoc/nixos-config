{ lib, pkgs, ... }:
{
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "ter-v18b";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true; # same layout on the tty as in sway
  };

  hardware.enableRedistributableFirmware = true;

  # Every host keeps /, /home and /nix as subvolumes of one btrfs filesystem.
  # hardware-configuration.nix supplies the device and subvol= for each mount;
  # list options from different modules are concatenated, so the following
  # are added to that without touching the generated file.
  fileSystems = lib.genAttrs [ "/" "/home" "/nix" ] (_: {
    options = [
      "compress=zstd"
      "noatime"
    ];
  });

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  environment.systemPackages = [
    # Utils
    pkgs.wget
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
    pkgs.acpi
  ];
}
