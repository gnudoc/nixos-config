{ ... }:
let
  theme = import ../theme.nix;
  c = theme.colors;
in
{
  services.mako = {
    enable = true;
    font = "Noto Sans 10";
    backgroundColor = "#${c.bg}f2";
    textColor = "#${c.fg}";
    borderColor = "#${c.cyan}";
    progressColor = "over #${c.green}";
    defaultTimeout = 5000;

    extraConfig = ''
      [urgency=critical]
      border-color=#${c.red}
      default-timeout=0
    '';
  };
}
