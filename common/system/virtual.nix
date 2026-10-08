{ pkgs, ... }:
{
  # Full VMs
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      #ovmf.enable = true; # apparently this is available by default now
    };
  };

  programs.virt-manager.enable = true;

  # Lightweight containers, alternative to LXD; needs nftables
  networking.nftables.enable = true;
  virtualisation.incus.enable = true;
  # but the nixos firewall will block dhcp and dns reqs from the containers/VMs
  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "virbr0"
  ];

  # CLI tools for ephemeral VMs
  environment.systemPackages = with pkgs; [
    quickemu
    virt-viewer
    incus
  ];
}
