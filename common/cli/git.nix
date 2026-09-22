{ user, osConfig, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      core.autocrlf = "input";
      github.user = "gnudoc";
      user.name = "Aijaz Mohammad";
      user.email = "20248043+gnudoc@users.noreply.github.com";
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };

    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };
  };
  home.file.".ssh/allowed_signers".text = ''
    20248043+gnudoc@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 "${user}@${osConfig.networking.hostName}"
  '';
}
