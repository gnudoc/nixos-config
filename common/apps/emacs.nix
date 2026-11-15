{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # consult
    ripgrep
    fd
    nixd
    nixfmt
    python3
    nerd-fonts.symbols-only # wanted by nerd-icons
    curl
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      # --- Compiled ---
      epkgs.treesit-grammars.with-all-grammars
      epkgs.ghostel
      epkgs.pdf-tools
      # --- System/Core stuff ---
      epkgs.no-littering
      epkgs.bluetooth
      epkgs.daemons # a nice interface for systemctl
      epkgs.journalctl-mode # a nice interface for journalctl
      # --- UI & Theming ---
      epkgs.doom-themes
      epkgs.doom-modeline
      epkgs.nerd-icons
      epkgs.nerd-icons-dired
      epkgs.rainbow-delimiters
      # --- Minibuffer, Completion ---
      epkgs.orderless
      epkgs.consult
      epkgs.embark
      epkgs.embark-consult
      epkgs.corfu
      epkgs.nerd-icons-corfu
      epkgs.cape
      # --- Org, Markdown ---
      epkgs.markdown-mode
      epkgs.ox-gfm
      epkgs.org-modern
      # --- Org-babel ---
      epkgs.ob-nix
      # --- Languages, Dev Tools ---
      epkgs.nix-mode
      # --- Project, Git ---
      epkgs.magit
      epkgs.forge
      # --- RSS ---
      epkgs.elfeed
      epkgs.elfeed-protocol
      # --- Environment Integration ---
      epkgs.envrc
      # --- Make eshell awesome ---
      epkgs.eshell-syntax-highlighting
      epkgs.esh-autosuggest
    ];
  };

  # for home manager to make the emacs systemd unit
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
  };
  # inject a custom line into the [Service] line of the home manager derived unit
  systemd.user.services.emacs.Service = {
    Environment = [
      "GDK_BACKEND=wayland"
      "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}"
    ];
  };
}
