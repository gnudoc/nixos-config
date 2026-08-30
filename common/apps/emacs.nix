{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # consult, vertico
    ripgrep
    fd
    nixd
    nixfmt
    python3
    emacs-all-the-icons-fonts
    nerd-fonts.symbols-only # doom-modeline wants nerd-icons, which wants symbols-only
    dtach
    curl
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      # --- Compiled ---
      epkgs.treesit-grammars.with-all-grammars
      epkgs.vterm
      epkgs.ghostel
      epkgs.pdf-tools
      # --- System/Core stuff ---
      epkgs.no-littering
      epkgs.gcmh
      epkgs.bluetooth
      epkgs.daemons # a nice interface for systemctl
      epkgs.journalctl-mode # a nice interface for journalctl
      epkgs.nixos-options
      epkgs.nix-update
      # --- UI & Theming ---
      epkgs.doom-themes
      epkgs.doom-modeline
      epkgs.all-the-icons
      epkgs.nerd-icons
      epkgs.rainbow-delimiters
      # --- Minibuffer, Completion ---
      epkgs.vertico
      epkgs.orderless
      epkgs.consult
      epkgs.marginalia
      epkgs.embark
      epkgs.embark-consult
      epkgs.corfu
      epkgs.kind-icon
      epkgs.cape
      epkgs.helpful
      epkgs.which-key
      # --- Org, Markdown ---
      epkgs.markdown-mode
      epkgs.ox-gfm
      epkgs.org-modern
      # --- Org-babel ---
      epkgs.ob-nix
      # --- Languages, Dev Tools ---
      epkgs.rec-mode
      epkgs.treesit-auto
      epkgs.prettier-js
      epkgs.nodejs-repl
      epkgs.nix-mode
      epkgs.auctex
      epkgs.haskell-mode
      # --- Project, Git ---
      epkgs.projectile
      epkgs.consult-projectile
      epkgs.magit
      epkgs.forge
      epkgs.transient
      epkgs.pinentry
      # --- Dired ---
      epkgs.all-the-icons-dired
      epkgs.dired-hide-dotfiles
      # --- RSS ---
      epkgs.elfeed
      epkgs.elfeed-protocol
      # --- Environment Integration ---
      epkgs.envrc
      epkgs.inheritenv
      epkgs.exec-path-from-shell
      epkgs.detached
      # --- Make eshell awesome ---
      epkgs.eshell-syntax-highlighting
      epkgs.esh-autosuggest
      epkgs.eshell-z
      #epkgs.eat # could throw to it from eshell when a terminal is needed, could be nice if we can get it working
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
    Environment = "GDK_BACKEND=wayland";
  };
}
