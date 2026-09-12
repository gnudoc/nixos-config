{ ... }:

{
  programs.git = {
    enable = true;

    userName = "Aijaz Mohammad";
    userEmail = "20248043+gnudoc@users.noreply.github.com";

    settings = {
      core.autocrlf = "input";
      github.user = "gnudoc";
    };

    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };

    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };
  home.file.".ssh/allowed_signers".text = ''
    20248043+gnudoc@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 nij@galvorn
  '';
}
