{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # consult, vertico
    ripgrep
    fd
    nixd
    nixfmt
    python3
    nerd-fonts.symbols-only # wanted by nerd-icons
    dtach
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
      epkgs.gcmh
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
      epkgs.vertico
      epkgs.orderless
      epkgs.consult
      epkgs.marginalia
      epkgs.embark
      epkgs.embark-consult
      epkgs.corfu
      epkgs.kind-icon
      epkgs.cape
      epkgs.which-key # remove this as emacs 31 has it inbuilt?
      # --- Org, Markdown ---
      epkgs.markdown-mode
      epkgs.ox-gfm
      epkgs.org-modern
      # --- Org-babel ---
      epkgs.ob-nix
      # --- Languages, Dev Tools ---
      epkgs.nix-mode
      epkgs.auctex
      epkgs.haskell-mode
      # --- Project, Git ---
      epkgs.magit
      epkgs.forge
      epkgs.transient # auto-grabbed as depenedency of magit, remove?
      epkgs.pinentry
      # --- Dired ---
      epkgs.dired-hide-dotfiles
      # --- RSS ---
      epkgs.elfeed
      epkgs.elfeed-protocol
      # --- Environment Integration ---
      epkgs.envrc
      epkgs.inheritenv # autograbbed as dependency of envrc, remove?
      epkgs.exec-path-from-shell
      epkgs.detached
      # --- Make eshell awesome ---
      epkgs.eshell-syntax-highlighting
      epkgs.esh-autosuggest
      epkgs.eshell-z
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
      # enable once we've enabled ssh-agent service in security/ssh.nix
    ];
  };
}
