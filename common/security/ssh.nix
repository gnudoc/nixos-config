{ pkgs, ... }:

{
  home.packages = [ pkgs.cloudflared ];

  # Create ~/.ssh/sockets dir for ssh-nas-tunnel
  systemd.user.tmpfiles.rules = [
    "d %h/.ssh/sockets 0700 - - - -"
  ];
  services.ssh-agent.enable = true;
  # The above means the ssh socket is made so the emacs daemon can grab
  # the SSH_AUTH_SOCK (see emacs.nix). This and the ssh-add in zsh.nix
  # mean smooth git commits and pushes
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # This include is so that the public repo has infrastructure details
    # secured by age-nix
    includes = [ "/run/agenix/ssh_config" ];
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
}
