{
  writeShellApplication,
  gnutar,
  coreutils,
}:

writeShellApplication {
  name = "laptop-backup-prepare";
  runtimeInputs = [
    gnutar
    coreutils
  ];
  text = ''
    RESTRICTED_PATHS=("/var/lib/bluetooth/" "/etc/NetworkManager/system-connections/")
    PATHS_TO_BACKUP=()
    for path in "''${RESTRICTED_PATHS[@]}"; do
        if [ -e "$path" ]; then
           PATHS_TO_BACKUP+=("$path")
        fi
    done
    if [ ''${#PATHS_TO_BACKUP[@]} -gt 0 ]; then
       tar -czPf - "''${PATHS_TO_BACKUP[@]}" || true
    fi
  '';
}
