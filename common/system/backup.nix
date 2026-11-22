{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.backup;
  user = config.my.user;
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
    text = ''
      set -euo pipefail
      TARGET_ARCHIVE="/home/${user}/.config/laptop-backup/secure-configs.tar.gz"
      mkdir -p "$(dirname "$TARGET_ARCHIVE")"
      echo "Archiving system security paths..."
      tar -czPf "$TARGET_ARCHIVE" /var/lib/bluetooth \
        /etc/NetworkManager/system-connections /etc/ssh || true
      chown ${user}:users "$TARGET_ARCHIVE"
      chmod 600 "$TARGET_ARCHIVE"
      # Note: The remote authorized_keys uses `rrsync` to force the destination
      # to `/mnt/main-pool/${config.networking.hostName}-backup/home/`. 
      # Targeting `:/` here is expected; the NAS jail handles the routing.
      echo "Syncing ~${user} to ${cfg.host}...";
      rsync -a --partial --delete --info=stats1 --exclude-from="${excludes}" \
        -e "ssh -l ${config.networking.hostName}_backup -i ${config.age.secrets.laptop_backup_key.path} -o IdentitiesOnly=yes" \
        "/home/${user}/" "${cfg.host}:/"
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
    age.secrets.laptop_backup_key = {
      file = ../../secrets/${config.networking.hostName}_backup_key.age;
      mode = "0400";
      owner = "root";
    };
    systemd.services.system-backup = {
      description = "Backup ${config.networking.hostName} to NAS via tailscale";
      serviceConfig = {
        type = "oneshot";
        StateDirectory = stateDir;
        ExecStart = "${backupScript}/bin/system-backup";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
    systemd.timers.system-backup = {
      description = "Run backup at 23/53min past each hour";
      timerConfig = {
        OnCalendar = "*:23,53:00";
        Persistent = true;
        RandomizedDelaySec = "60s";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
