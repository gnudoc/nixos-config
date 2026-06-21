{ pkgs, user, ... }:
let
  backupPrepare = pkgs.callPackage ../cli/backup-prepare.nix { };
in

{
  security.pam.services.swaylock = { };
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Grant passwordless sudo specifically for this generated binary
  security.sudo.extraRules = [
    {
      users = [ user ];
      commands = [
        {
          command = "${backupPrepare}/bin/laptop-backup-prepare";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}
