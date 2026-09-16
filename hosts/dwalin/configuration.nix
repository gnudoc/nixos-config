{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/boot.nix # bootloader, hibernating, which kernel
    ../../common/system/networking.nix # networkmanager, dnsutils
    ../../common/system/desktop.nix # Sway, XDG portals, pipewire, bluetooth
    ../../common/system/security.nix # PAM, Polkit, sudo rule for laptop backup
    ../../common/system/nix.nix # GC, experimental features, nix tools
    ../../common/system/core.nix
  ];

  environment.systemPackages = [
    pkgs.vlc
  ];

  # avoid the 90second startup wait for TPM
  boot.blacklistedKernelModules = [
    "tpm_crb"
    "tpm_tis"
    "tpm_tis_core"
  ];
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  boot.resumeDevice = "/dev/disk/by-label/SWAP";
  boot.kernelParams = [
    "i915.enable_psr=0"
    "random.trust_cpu=on"
  ];

  networking.hostName = "dwalin";

  services.tailscale = {
    #enable = true;
    #useRoutingFeatures = "client";
  };
}
