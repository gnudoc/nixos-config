{
  config,
  inputs,
  pkgs,
  ...
}:

{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # The agenix command, at the version flake.lock pins for the module.
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

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
