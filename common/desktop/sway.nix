{
  lib,
  pkgs,
  ...
}:

let
  theme = import ../theme.nix;
  c = theme.colors;
  idleHandler = pkgs.writeShellScriptBin "swayidle-handler" ''
    ${pkgs.swayidle}/bin/swayidle -w \
      timeout 300 'pgrep -x swaylock || ${pkgs.swaylock}/bin/swaylock -f -c ${c.bg}' \
      timeout 330 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
      resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
      before-sleep 'pgrep -x swaylock || ${pkgs.swaylock}/bin/swaylock -f -c ${c.bg}'
  '';
in

{
  home.packages = with pkgs; [
    swaylock
    swayidle
    grim
    slurp
    wl-clipboard
    brightnessctl
  ];
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    config = rec {
      modifier = "Mod4";
      bars = [ ]; # disable sway's bar
      terminal = "emacsclient -c -e \"(vterm)\" -a \"\"";
      menu = "rofi -show combi -modes combi -combi-modes \"window,drun,ssh\"";
      fonts = {
        names = [ "Noto Sans" ];
        size = 10.0;
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_variant = "dvorak";
          xkb_options = "ctrl:swapcaps";
        };
        "type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "disabled";
          middle_emulation = "enabled";
        };
      };
      output = {
        "eDP-1" = {
          position = "0,0";
          scale = "1";
        };
      };
      gaps = {
        inner = 2;
        outer = 5;
      };
      window = {
        border = 2;
        titlebar = false;
        commands = [
          {
            command = "opacity 0.95";
            criteria = {
              class = ".*";
            };
          }
          {
            command = "opacity 0.95";
            criteria = {
              app_id = ".*";
            };
          }
          {
            command = "opacity 1.0";
            criteria = {
              app_id = "rofi";
            };
          }
          {
            command = "opacity 0.99";
            criteria = {
              app_id = "chromium";
            };
          }
          {
            command = "opacity 0.99";
            criteria = {
              app_id = "brave-browser";
            };
          }
        ];
      };
      floating = {
        border = 1;
        titlebar = true;
      };
      colors = {
        focused = {
          border = "#${c.cyan}";
          background = "#${c.cyan}";
          text = "#${c.black}";
          indicator = "#${c.cyan}";
          childBorder = "#${c.cyan}";
        };
      };
      startup = [
        # adding systemd.enable = true to the programs.waybar module should mean we don't need this
        # But it might be needed to have the dbus / systemd env immediately available after hibernate
        {
          command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP SSH_AUTH_SOCK";
        }
        {
          command = "hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP SSH_AUTH_SOCK";
        }
        {
          command = "${idleHandler}/bin/swayidle-handler";
        }
      ];
      keybindings = lib.mkOptionDefault {
        "${modifier}+Escape" = "exec swaylock -f -c ${c.bg}";
        "${modifier}+b" = "exec chromium";
        "${modifier}+Shift+b" = "exec brave";
        "${modifier}+r" = "exec ${menu}";
        "${modifier}+q" = "kill";
        "${modifier}+m" = "exec swaymsg exit";
        "${modifier}+Tab" = "layout tabbed";
        "${modifier}+Shift+Tab" = "layout toggle split";
        "${modifier}+w" = "exec pkill waybar";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec emacsclient -c -e \"(call-interactively 'dired)\" -a \"\"";
        "${modifier}+g" = "exec emacsclient -c -e '(magit-status)' -a \"\"";
        "${modifier}+e" = "exec emacsclient -c -e \"(scratch-buffer)\"";
        "${modifier}+s" = "exec rofi -show p -modi p:rofi-power-menu";

        "XF86AudioRaiseVolume" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl s 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "Print" = "exec grim -g \"$(slurp -d)\"";
        "Shift+Print" = "exec grim -g \"$(slurp)\" - | tee \"$HOME/$(date +'%s_grim.png')\" | wl-copy";
      };
    };
    extraConfig = ''
      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next
    '';
  };
}
