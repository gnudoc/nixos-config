{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  theme = import ../theme.nix;
  c = theme.colors;
  # mod, notify, menu are so we don't have to use config = rec {...}
  mod = "Mod4";
  lock = "${lib.getExe pkgs.swaylock} -f -c ${c.bg}";
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
  notify = lib.getExe pkgs.libnotify;
  menu = ''rofi -show combi -modes combi -combi-modes "window,drun,ssh"'';

  # A new Emacs frame, named `name` so that sway rules can match it, showing
  # the result of evaluating `elisp`. -a "" starts the daemon if it isn't up.
  emacsFrame = name: elisp: ''emacsclient -c -F '((name . "${name}"))' -e "${elisp}" -a ""'';
  terminal = emacsFrame "ghostel-term" "(ghostel-new)";
in
{
  home.packages = [
    pkgs.swaylock
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.brightnessctl
  ];
  services.swayidle = {
    enable = true;
    events.before-sleep = lock;
    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 330;
        command = "${swaymsg} 'output * power off'";
        resumeCommand = "${swaymsg} 'output * power on'";
      }
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    # Use the sway that programs.sway installs (system/desktop.nix) rather
    # than building a second, differently wrapped copy for the user profile.
    package = osConfig.programs.sway.package;
    checkConfig = false;
    config = {
      modifier = mod;
      bars = [ ]; # disable sway's bar
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
      keybindings = lib.mkOptionDefault {
        "${mod}+Escape" = "exec ${lock}";
        "${mod}+b" = "exec chromium";
        "${mod}+r" = "exec ${menu}";
        "${mod}+q" = "kill";
        "${mod}+m" = "exit";
        "${mod}+Tab" = "layout tabbed";
        "${mod}+Shift+Tab" = "layout toggle split";
        "${mod}+w" = "exec pkill waybar";
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+d" = "exec ${emacsFrame "dired" "(call-interactively 'dired)"}";
        "${mod}+g" = "exec ${emacsFrame "magit" "(magit-status)"}";
        "${mod}+e" = "exec ${emacsFrame "emacs" "(scratch-buffer)"}";
        "${mod}+s" = "exec rofi -show p -modi p:rofi-power-menu";
        "${mod}+Shift+e" =
          "exec systemctl --user restart emacs.service && ${notify} 'Emacs' 'Daemon restarted successfully' || ${notify} -u critical 'Emacs' 'Failed to restart daemon'";

        "XF86AudioRaiseVolume" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl s 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "Print" = ''exec grim -g "$(slurp -d)"'';
        "Shift+Print" = ''exec grim -g "$(slurp)" - | tee "$HOME/$(date +'%s_grim.png')" | wl-copy'';
      };
    };
    extraConfig = ''
      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next
    '';
  };
}
