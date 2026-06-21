{
  config,
  pkgs,
  lib,
  osConfig,
  backupHost,
  ...
}:

let
  destDataset = "main-pool/${osConfig.networking.hostName}-backup";
  configDir = "${config.home.homeDirectory}/.config/laptop-backup";
  excludesFile = "${configDir}/excludes.txt";
  markerFile = "${config.home.homeDirectory}/.local/state/last_backup";
  backupPrepare = pkgs.callPackage ./backup-prepare.nix { };
  # Main Backup Script
  laptopBackup = pkgs.writeShellApplication {
    name = "laptop-backup";
    runtimeInputs = [
      pkgs.rsync
      pkgs.openssh
      pkgs.coreutils
      pkgs.cloudflared
    ];
    text = ''
      TARGET_ARCHIVE="$HOME/.config/laptop-backup/secure-configs.tar.gz"
      echo "Bundling secure system configurations..."
      mkdir -p "$(dirname "$TARGET_ARCHIVE")"
      # Run the system script as root, but save the output as the user
      # we have to call the absolute path of the sudo wrapper, because the system sudo isn't
      # available due to our runtimeInputs, and adding pkgs.sudo doesn't work because it can't
      # run that version with the right privs. NIXOS being NIXOS.
      # The line below isn't a comment, it tells nix not to worry about sudo and >
      # shellcheck disable=SC2024
      /run/wrappers/bin/sudo ${backupPrepare}/bin/laptop-backup-prepare > "$TARGET_ARCHIVE"
      # Lock down the file permissions
      chmod 600 "$TARGET_ARCHIVE"
      echo "Backing up home directory..."
      if rsync -a --partial --info=stats1 --delete \
          --exclude-from="${excludesFile}" \
          -e ssh "$HOME/" "${backupHost}:/mnt/${destDataset}/home/"; then
          echo "Backup successful. Updating marker..."
          mkdir -p "$(dirname "${markerFile}")"
          touch "${markerFile}"
      else
          echo "Error backing up home directory!"
          exit 1
      fi
    '';
  };
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
  # Install custom scripts so they're in $USER's $PATH
  home.packages = [
    laptopBackup
    waybarBackupStatus
  ];
  home.file."${excludesFile}".text = ''
    # --- Security & Shell ---
    .authinfo
    .authinfo.gpg
    .bash_history
    .zsh_history
    # --- General Caches & Trash ---
    .cache/
    .Trash/
    .local/share/Trash/
    tmp/
    Downloads/not-for-backup/
    # --- Virtualization & Containers ---
    ISOs/
    VMs/
    .local/share/containers/
    # --- Developer Caches & Build Outputs ---
    .cargo/registry/
    .npm/
    node_modules/
    __pycache__/
    target/
    /.cabal/
    /.ghcup/
    build/
    dist/
    # --- IDEs & Editors ---
    # If ever needed
    #.config/Code/
    #.config/VSCodium/
    #.vscode/extensions/
    # --- Browsers & Electron App Caches ---
    # Again, mostly hypothetical
    #.config/google-chrome/
    .config/BraveSoftware/
    #.config/vivaldi/
    .config/chromium/
    #.config/chromium-proxied/
    #.mozilla/firefox/
    #.config/discord/Cache/
    #.config/Slack/Cache/
    # --- Media & Desktop ---
    .local/wallpapers/
    .local/share/wallpapers/
    .local/share/baloo/
    # --- Specific Project/Work Exclusions ---
    Projects/tor/
    pdfs-from-girion/
    # --- Gaming Exclusions ---
    # If I ever have the time to game again...
    #.local/share/Steam/steamapps/common/
    #.local/share/Steam/steamapps/shadercache/
  '';
  systemd.user.services.laptop-backup = {
    Unit = {
      Description = "Backup NixOS laptop to TrueNAS server";
    };
    Service = {
      Type = "oneshot";
      # Because laptopBackup is a Nix package, we use getExe to find it in the Nix store
      ExecStart = lib.getExe laptopBackup;
      Restart = "on-failure";
      RestartSec = "60";
      StartLimitBurst = 5;
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
  systemd.user.timers.laptop-backup = {
    Unit = {
      Description = "Run laptop backup at 23 and 53 min past each hour or on boot";
    };
    Timer = {
      OnCalendar = "*-*-* *:23,53:00";
      Persistent = true;
      RandomizedDelaySec = "60";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
