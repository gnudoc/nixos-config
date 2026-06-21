{ config, tunnelAlias, ... }:

{
  # --- ZSH, Starship, and Direnv ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      extended = true; # timestamps
    };
    shellAliases = {
      btc = "bluetoothctl";
      proxsh = "ssh -D 1080 ${tunnelAlias}";
      ls = "ls --color=auto -F";
      ll = "ls -lh --color=auto -F";
      la = "ls -lah --color=auto -F";
      l = "ls -A --color=auto -F";
      less = "less -RiFX";
      wget = "wget -c";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
    };
    # Extra stuff that goes in .zshenv
    envExtra = ''
      typeset -U PATH path
    '';
    # Extra stuff that goes in .zshrc
    # setopts, vterm integration, clever aliases, command-line-editor
    initContent = ''
      setopt appendhistory autocd extendedglob autopushd
      setopt beep notify
      unsetopt nomatch
      bindkey -e
      if [[ "$INSIDE_EMACS" = 'vterm' ]] && [[ -n ''${EMACS_VTERM_PATH} ]]; then
          if [[ -f ''${EMACS_VTERM_PATH}/etc/vterm.zsh ]]; then
              source ''${EMACS_VTERM_PATH}/etc/vterm.zsh
          fi
      fi
      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      elif [[ "$INSIDE_EMACS" = 'vterm' ]]; then
        export EDITOR='emacsclient'
      else
        export EDITOR='emacsclient -c'
        export SUDO_EDITOR='visudo-emacs'
      fi
      alias -g G="| grep"
      alias -g L="| less"
      if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
        alias ff='vterm_cmd find-file'
        alias vd='vterm_cmd dired "$(pwd)"'
        alias mag='vterm_cmd magit-status "$(pwd)"'
        alias -s org='emacsclient -n'
        alias -s txt='emacsclient -n'
        alias -s md='emacsclient -n'
      else
        alias -s org='emacsclient -c'
        alias -s txt='emacsclient -c'
        alias -s md='emacsclient -c'
      fi
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '\ee' edit-command-line
    '';
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
