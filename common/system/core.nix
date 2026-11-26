{ pkgs, ... }:
{
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "ter-v18b";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true; # same layout on the tty as in sway
  };

  hardware.enableRedistributableFirmware = true;

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
