{
  config,
  pkgs,
  ...
}:

let
  markerFile = "${config.home.homeDirectory}/.local/state/last_backup";
  # Main Backup Script now in a backup.nix module able to access root
  # Waybar status script
  waybarBackupStatus = pkgs.writeShellApplication {
    name = "backup-status-on-waybar";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      MARKER_FILE="${markerFile}"
      if [ ! -f "$MARKER_FILE" ]; then
          echo '{"text": "Unknown", "tooltip": "No backup marker found", "class": "critical"}'
          exit 0
      fi
      LAST_BACKUP=$(stat -c %Y "$MARKER_FILE")
      NOW=$(date +%s)
      DIFF_HOURS=$(( (NOW - LAST_BACKUP) / 3600 ))
      DIFF_DAYS=$(( DIFF_HOURS / 24 ))
      if [ "$DIFF_HOURS" -lt 24 ]; then
          CLASS="good"
          TEXT="''${DIFF_HOURS}h"
      elif [ "$DIFF_DAYS" -lt 3 ]; then
          CLASS="warning"
          TEXT="''${DIFF_DAYS}d"
      else
          CLASS="critical"
          TEXT="''${DIFF_DAYS}d!"
      fi
      echo "{\"text\": \"$TEXT\", \"tooltip\": \"Last successful backup: $(date -d @"$LAST_BACKUP")\", \"class\": \"$CLASS\"}"
    '';
  };
in
{
  home.packages = [
    waybarBackupStatus
  ];
}
