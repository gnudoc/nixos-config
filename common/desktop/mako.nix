{ ... }:
let
  theme = import ../theme.nix;
  c = theme.colors;
in
{
  services.mako = {
    enable = true;
    settings = {
      font = "Noto Sans 10";
      background-color = "#${c.bg}f2";
      text-color = "#${c.fg}";
      border-color = "#${c.cyan}";
      progress-color = "over #${c.green}";
      default-timeout = 5000;
    };
    extraConfig = ''
      [urgency=critical]
      border-color=#${c.red}
      default-timeout=0
    '';
  };
}
