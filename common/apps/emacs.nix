# Emacs also relies on:
#   direnv & nix-direnv (cli/zsh.nix)
#   JetBrainsMono Nerd Font & Noto Sans (system/desktop.nix)
#   ssh-agent (security/ssh.nix)

{ pkgs, config, ... }:

{
  home.packages = [
    pkgs.ripgrep # consult-ripgrep, project.el search
    pkgs.fd # consult-fd
    pkgs.nixd # nix lang server
    pkgs.nixfmt # formatter called by nixd
    pkgs.nerd-fonts.symbols-only # font for nerd-icons
    pkgs.curl # elfeed-use-curl
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      # === ~1 entry per use-package, with 2 known exceptions ===
      # --- Compiled ---
      epkgs.treesit-grammars.with-all-grammars # first exception
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
      epkgs.ob-nix # second exception
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
      epkgs.capf-autosuggest
    ];
  };

  # clangd's user-level config: the clang-tidy checks for every C++ project.
  # A project can still override them with a .clangd file of its own.
  xdg.configFile."clangd/config.yaml".text = ''
    Diagnostics:
      ClangTidy:
        Add: [
          "bugprone-*",
          "cppcoreguidelines-*",
          "modernize-*",
          "performance-*"
        ]
  '';

  # for home manager to make the emacs systemd unit
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
  };
  # Add to the [Service] section of the unit that services.emacs generates.
  # The daemon is started by systemd rather than from inside the sway session,
  # so tell it explicitly to use Wayland and where the ssh-agent socket is.
  systemd.user.services.emacs.Service.Environment = [
    "GDK_BACKEND=wayland"
    "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}"
  ];
}
