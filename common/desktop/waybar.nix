{ ... }:

let
  theme = import ../theme.nix;
  c = theme.colors;
in

{
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
        modules-right = [
          "custom/backup"
          "custom/sep"
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
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
            "7" = [ ];
            "8" = [ ];
            "9" = [ ];
          };
        };
        "sway/window" = {
          max-length = 40;
          icon = false;
        };
        clock = {
          format = "{:%H:%M}";
        };
        "custom/backup" = {
          exec = "backup-status-on-waybar";
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
          bat = "BAT0";
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
