let
  nij = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 nij@galvorn";
  galvorn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN51R854jRP+1zjkrph745TcT+29h4+VNL65yqVP9ODS root@galvorn";
  sure = "ssh-ed25519 AddYour/etc/ssh/ssh_host_ed25519_key.pubKeyHere root@sure";
in
{
  "eduroam.env.age".publicKeys = [
    nij
    galvorn
  ];
  "wifi.env.age".publicKeys = [
    nij
    galvorn
  ];
  "authinfo.age".publicKeys = [
    nij
    galvorn
  ];
  "ssh_config.age".publicKeys = [
    nij
    galvorn
  ];
  "tailscale.age".publicKeys = [
    nij
    galvorn
  ];
  "laptop_backup_key.age".publicKeys = [
    nij
    sure
    galvorn
  ];
  ## At some point it'll be worth setting up wireguard access to protonvpn/nordvpn etc instead of the
  ## browser extensions, and the wireguard credentials would be encrypted by age as well
}
