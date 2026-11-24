{ config, ... }:

{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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
