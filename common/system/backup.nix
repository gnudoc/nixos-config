# Twice-hourly rsync of $HOME to the backup server
# run as root by a systemd timer

{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.backup;
  user = config.my.user;
  home = config.users.users.${user}.home;
  hostname = config.networking.hostName;
  stateDir = "system-backup"; # in /var/lib/, instead of ~/.local/state/
  excludes = pkgs.writeText "backup-excludes.txt" ''
    .cache/
    .Trash/
    .local/share/Trash/
    Downloads/not-for-backup/
    target/
    node_modules/
    __pycache__/
    .direnv/
  '';
  backupScript = pkgs.writeShellApplication {
    name = "system-backup";
    runtimeInputs = [
      pkgs.rsync
      pkgs.openssh
      pkgs.coreutils
      pkgs.gnutar
      pkgs.gzip
    ];
    # writeShellApplication already runs the script under `set -euo pipefail`
    # and shellchecks it at build time.
    text = ''
      # Root-only system state that should survive a reinstall. It goes into
      # the user's home so that the rsync below picks it up.
      archive=${home}/.config/laptop-backup/secure-configs.tar.gz
      install -d -o ${user} -g users "$(dirname "$archive")"
      echo "Archiving system security paths..."
      # tar exits non-zero if a path is missing or a file changes while it is
      # being read; neither should stop the home directory being backed up.
      tar -czPf "$archive" /var/lib/bluetooth \
        /etc/NetworkManager/system-connections /etc/ssh || true
      chown ${user}:users "$archive"
      chmod 600 "$archive"
      # The server's authorized_keys pin this entry to `rrsync`, rooted at
      # `/mnt/main-pool/${hostname}-backup/home/. The ":/" destination is 
      # therefore that directory, not the server's real root.
      echo "Syncing ${home} to ${cfg.host}...";
      rsync -a --partial --delete --info=stats1 --exclude-from="${excludes}" \
        -e "ssh -l ${hostname}_backup -i ${config.age.secrets.laptop_backup_key.path} -o IdentitiesOnly=yes" \
        "${home}/" "${cfg.host}:/"
      touch ${cfg.markerFile}
    '';
  };
in
{
  options.my.backup = {
    enable = lib.mkEnableOption "the twice-hourly rsync of $HOME to the backup server";

    host = lib.mkOption {
      type = lib.types.str;
      default = "girion-tailscale";
      description = "SSH alias for the backup machine.";
    };
    markerFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${stateDir}/last-success";
      readOnly = true;
      description = ''
        Touched after every successful run. The waybar module reads its age
        (through osConfig) to show how old the last backup is.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.laptop_backup_key.file = ../../secrets/${hostname}_backup_key.age;

    systemd.services.system-backup = {
      description = "Back up ${home} to ${cfg.host}";
      serviceConfig = {
        type = "oneshot";
        ExecStart = lib.getExe backupScript;
        StateDirectory = stateDir;
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };

    systemd.timers.system-backup = {
      description = "Run backup at 23 and 53 minutes past each hour";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:23,53:00";
        Persistent = true; # catch up after sleep / power-off
        RandomizedDelaySec = "60s";
      };
    };
  };
}
