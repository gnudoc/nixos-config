# agenix: which key decrypts, and the secrets the user's own programs read.
# Secrets used by a single module are declared in the module instead
# (wifi in networking.nix, the backup key in backup.nix).
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  # agenix decrypts with the machine's ssh host key. The laptops don't run
  # sshd, so ask for the host keys to be generated anyway, and name the key
  # explicitly (agenix only finds it by itself when sshd is enabled).
  services.openssh.generateHostKeys = true;
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # The agenix command, at the version flake.lock pins for the module.
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # owner = the user, because these are read by the user's programs:
  #   authinfo   - Emacs auth-source
  #   ssh_config - Included from ~/.ssh/config (common/security/ssh.nix)
  age.secrets = {
    authinfo = {
      file = ../../secrets/authinfo.age;
      owner = config.my.user;
    };
    ssh_config = {
      file = ../../secrets/ssh_config.age;
      owner = config.my.user;
    };
  };
}
