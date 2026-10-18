{ ... }:

{
  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
    };
    extraConfig = ''
      filetype plugin indent on
      syntax enable
      autocmd FileType nix setlocal autoindent smartindent
    '';
  };
}
