{
  pkgs,
  config,
  backupHost,
  user,
  ...
}:
let
  markerFile = "/home/${user}/.local/state/last_backup";
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
      echo "Syncing ~${user} to ${backupHost}...";
      rsync -a --partial --delete --info=stats1 --exclude-from="${excludes}" \
        -e ssh "/home/${user}/" "${backupHost}:/"
      mkdir -p "$(dirname "${markerFile}")"
      chown ${user}:users "$(dirname "${markerFile}")"
      touch "${markerFile}"
      chown ${user}:users "${markerFile}"
    '';
  };
in
{
  age.secrets.laptop_backup_key = {
    file = ../../secrets/${config.networking.hostName}_backup_key.age;
    mode = "0400";
    owner = "root";
  };
  programs.ssh.extraConfig = ''
    Host ${backupHost}
      User ${config.networking.hostName}_backup
      IdentityFile ${config.age.secrets.laptop_backup_key.path}
      IdentitiesOnly yes
  '';
  systemd.services.system-backup = {
    description = "Backup ${config.networking.hostName} to NAS via tailscale";
    serviceConfig = {
      Type = "oneshot";
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
}
