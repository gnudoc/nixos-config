{ pkgs, ... }:

let
  theme = import ../theme.nix;
  c = theme.colors;
in

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono NF:size=12";
        pad = "8x8";
        term = "xterm-256color";
        shell = "${pkgs.zsh}/bin/zsh";
      };
      colors-dark = {
        alpha = "0.95";
        # Tokyo Night Theme
        foreground = c.fg;
        background = c.bg;
        regular0 = c.black;
        regular1 = c.red;
        regular2 = c.green;
        regular3 = c.yellow;
        regular4 = c.blue;
        regular5 = c.magenta;
        regular6 = c.cyan;
        regular7 = c.white;
        bright0 = c.br-black;
        bright1 = c.br-red;
        bright2 = c.br-green;
        bright3 = c.br-yellow;
        bright4 = c.br-blue;
        bright5 = c.br-magenta;
        bright6 = c.br-cyan;
        bright7 = c.br-white;
        dim0 = c.dim0;
        dim1 = c.dim1;
      };
      cursor = {
        style = "block";
        blink = "yes";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      scrollback = {
        lines = 10000;
      };
      url = {
        launch = "xdg-open \${url}";
        osc8-underline = "url-mode";
      };
    };
  };
}
