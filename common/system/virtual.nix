{ pkgs, ... }:
{
  # Full VMs
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      ovmf.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  # Lightweight containers, alternative to LXD
  virtualisation.incus.enable = true;

  # CLI tools for ephemeral VMs
  environment.systemPackages = with pkgs; [
    quickemu
    virt-viewer
    incus
  ];
}
