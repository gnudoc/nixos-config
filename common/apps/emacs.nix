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
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      # --- Compiled ---
      epkgs.treesit-grammars.with-all-grammars
      epkgs.vterm
      epkgs.pdf-tools
      # --- System/Core stuff ---
      epkgs.no-littering
      epkgs.gcmh
      epkgs.bluetooth
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
      # --- Environment Integration ---
      epkgs.envrc
      epkgs.inheritenv
    ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
  };
}
