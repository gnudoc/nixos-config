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
      # Root-only system state that should survive a reinstall. It gets tar'd
      # in the state dir and rsync'd along with $home. Previously was being
      # cp'd into the local home, so any user priv'd process could see it - bad.
      archive=/var/lib/${stateDir}/secure-configs.tar.gz

      # define and check for the system paths, so that tar's exit status is useful
      paths=()
      for p in /var/lib/bluetooth /etc/NetworkManager/system-connections /etc/ssh; do
        if [ -e "$p" ]; then paths+=("$p"); fi
      done

      echo "making temp copy of system paths..."
      tmp=$(mktemp "$archive.XXXXXX")
      trap 'rm -f "$tmp"' EXIT # delete the tempfile when the script exits
      status=0
      tar -czPf "$tmp" "''${paths[@]}" || status=$?
      if [ "$status" -le 1 ]; then
        echo "Archiving system paths..."
        mv "$tmp" "$archive"
      else
        echo "tar failed with status $status; keeping the previous archive" >&2
      fi


      # The server's authorized_keys pin this entry to `rrsync`, rooted at
      # `/mnt/main-pool/${hostname}-backup/home/. The ":/" destination is 
      # therefore that directory, not the server's real root.
      echo "Syncing ${home} to ${cfg.host}...";
      rsync -a --partial --delete --info=stats1 --exclude-from="${excludes}" \
        -e "ssh -l ${hostname}_backup -i ${config.age.secrets.laptop_backup_key.path} -o IdentitiesOnly=yes" \
        "$archive" "${home}/" "${cfg.host}:/"
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
        Type = "oneshot";
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
