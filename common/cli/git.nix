{ config, osConfig, ... }:
let
  email = "20248043+gnudoc@users.noreply.github.com";
in
{
  programs.git = {
    enable = true;

    settings = {
      core.autocrlf = "input";
      github.user = "gnudoc";
      user.name = "Aijaz Mohammad";
      user.email = email;
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519";
      signByDefault = true;
      # Who git trusts when it *verifies* a signature (git log --show-signature):
      # one line per key, "<principal> <key type> <public key> <comment>".
      allowedSigners = ''
        ${email} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 ${config.home.username}@${osConfig.networking.hostName}
      '';
    };
  };
}
