{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  theme = import ../theme.nix;
  c = theme.colors;
  backup = osConfig.my.backup;

  # Prints the age of the last successful backup as JSON for waybar's
  # custom/backup module below. The marker is touched by system/backup.nix.
  backupStatus = pkgs.writeShellApplication {
    name = "backup-status-on-waybar";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      marker=${backup.markerFile}
      if [ ! -f "$marker" ]; then
          echo '{"text": "Unknown", "tooltip": "No backup marker found", "class": "critical"}'
          exit 0
      fi
      last=$(stat -c %Y "$marker")
      hours=$(( ($(date +%s) - last) / 3600 ))
      days=$(( hours / 24 ))
      if [ "$hours" -lt 24 ]; then
          class="good"
          text="''${hours}h"
      elif [ "$days" -lt 3 ]; then
          class="warning"
          text="''${days}d"
      else
          class="critical"
          text="''${days}d!"
      fi
      echo "{\"text\": \"$text\", \"tooltip\": \"Last successful backup: $(date -d @"$last")\", \"class\": \"$class\"}"
    '';
  };
in

{
  xsession.preferStatusNotifierItems = true;
  services.network-manager-applet.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        spacing = 7;
        modules-left = [
          "sway/workspaces"
          "sway/window"
        ];
        modules-center = [ "clock" ];
        modules-right =
          # backup indicator only on hosts that are backed up
          lib.optionals backup.enable [
            "custom/backup"
            "custom/sep"
          ]
          ++ [
            "wireplumber"
            "custom/sep"
            "backlight"
            "custom/sep"
            "battery"
            "custom/sep"
            "tray"
          ];
        "sway/workspaces" = {
          format = "{name}";
          disable-scroll = true;
          all-outputs = true;
          persistent-workspaces = lib.genAttrs (map toString (lib.range 1 10)) (_: [ ]);
        };
        "sway/window" = {
          max-length = 40;
          icon = false;
        };
        # see https://man.archlinux.org/man/extra/waybar/waybar-clock.5.en for some examples
        clock = {
          format = "{:%H:%M}  ";
          format-alt = "{:%A, %B %d, %Y (%R)} 󰃰 ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-cl = 3;
            weeks-pos = "right";
            first-day-of-week = 1;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          "actions" = {
            "on-click-right" = "mode";
            "on-click-forward" = "tz_up";
            "on-click-backward" = "tz_down";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };
        "custom/backup" = {
          exec = lib.getExe backupStatus;
          return-type = "json";
          interval = 3600;
          format = "  {}";
        };
        wireplumber = {
          format = "󱄾 {volume}%";
          max-volume = 100;
          scroll-step = 5;
        };
        battery = {
          interval = 60;
          format = "{icon} {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        backlight = {
          format = "󰃟 {percent}%";
        };
        tray = {
          icon-size = 14;
          spacing = 10;
        };
        "custom/sep" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };
      };
    };
    style = ''
      @define-color bg    #${c.bg};
      @define-color fg    #${c.fg};
      @define-color blk   #${c.black};
      @define-color red   #${c.red};
      @define-color grn   #${c.green};
      @define-color ylw   #${c.yellow};
      @define-color blu   #${c.blue};
      @define-color mag   #${c.magenta};
      @define-color cyn   #${c.cyan};
      @define-color brblk #${c.br-black};
      @define-color wht   #${c.white};
      * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 16px;
          font-weight: bold;
          padding: 0;
          margin: 0;
      }
      #waybar {
          color: @fg;
          background-color: @bg;
      }
      #workspaces button {
          color: @cyn;
          padding: 0 3px;
          background: transparent;
          border-bottom: 3px solid @bg;
      }
      #workspaces button.active {
          color: @cyn;
          border-bottom: 3px solid @mag;
      }
      #workspaces button.empty {
          color: @wht;
      }
      #workspaces button.empty.active {
          color: @cyn;
          border-bottom: 3px solid @mag;
      }
      #wireplumber,
      #battery,
      #backlight,
      #tray {
          padding: 0 2px;
          color: @wht;
      }
      #wireplumber {
          color: @cyn;
          border-bottom: 3px solid @cyn;
      }
      #battery {
          color: @mag;
          border-bottom: 3px solid @mag;
      }
      #backlight {
          color: @grn;
          border-bottom: 3px solid @grn;
      }
      #custom-backup {
          color: @blu;
          padding: 0 5px;
          border-bottom: 3px solid @blu;
      }
      #custom-backup.good {
          color: @grn;
          border-bottom-color: @grn;
      }
      #custom-backup.warning {
          color: @ylw;
          border-bottom-color: @ylw;
      }
      #custom-backup.critical {
          color: @red;
          border-bottom-color: @red;
      }
    '';
  };
}
