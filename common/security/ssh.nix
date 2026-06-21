{ pkgs, ... }:

{
  home.packages = [ pkgs.cloudflared ];

  # Create ~/.ssh/sockets dir for ssh-nas-tunnel
  systemd.user.tmpfiles.rules = [
    "d %h/.ssh/sockets 0700 - - - -"
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # This include is so that we don't have infrastruc details on public gh
    includes = [ "~/.ssh/config.local" ];
    settings = {
      "*" = {
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };
    };
  };
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };
}
