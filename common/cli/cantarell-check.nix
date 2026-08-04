{ pkgs, lib, ... }:

let
  cantarellCheck = pkgs.writeShellApplication {
    name = "cantarell-font-issue-check";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.libnotify
    ];
    text = ''
      # Check nixos/nixpkgs issue #535887 status using the api
      STATUS=$(curl -s "https://api.github.com/repos/NixOS/nixpkgs/issues/535887" | jq -r '.state')

      if [ "$STATUS" = "closed" ]; then
         notify-send -u critical "Nixpkgs Cantarell Fonts Fix" "Nixpkgs issue #535887 closed, we can likely remove the pinning code from flake.nix and hosts/dwalin/configuration.nix."
      fi
    '';
  };
in
{
  # put the script in the PATH so we can run it manually if we want.
  home.packages = [ cantarellCheck ];
  systemd.user.services.cantarell-issue-check = {
    Unit = {
      Description = "Check Nixpkgs cantarell fonts issue status";
    };
    Service = {
      Type = "oneshot";
      # lib.getExe nicely grabs the binary path from nix store
      ExecStart = lib.getExe cantarellCheck;
    };
  };
  systemd.user.timers.cantarell-font-issue-check = {
    Unit = {
      Description = "Weekly check for Nixpkgs Cantarell Fonts issue being resolved";
    };
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
