{ user, ... }:

{
  imports = [
    ./apps/brave.nix
    ./apps/chromium.nix
    ./apps/emacs.nix
    ./apps/foot.nix
    ./cli/backup.nix
    ./cli/battery.nix
    ./cli/git.nix
    ./cli/vim.nix
    ./cli/zsh.nix
    ./desktop/gtk.nix
    ./desktop/rofi.nix
    ./desktop/sway.nix
    ./desktop/waybar.nix
    ./desktop/wpaperd.nix
    ./security/gpg.nix
    ./security/ssh.nix
  ];
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  #for chromium/electron stuff in wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
