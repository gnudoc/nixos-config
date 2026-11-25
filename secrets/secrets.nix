# Read by agenix, not by NixOS. After changing a list (eg a new host),
# run `agenix --rekey` in ./secrets
let
  # my key, so I can edit the file
  nij = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 nij@galvorn";
  # host keys (/etc/ssh/ssh_host_ed25519_key.pub), so that each machine can decrypt
  galvorn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN51R854jRP+1zjkrph745TcT+29h4+VNL65yqVP9ODS root@galvorn";
  # sure = "ssh-ed25519 AddYour/etc/ssh/ssh_host_ed25519_key.pubKeyHere root@sure";

  # secrets used by common/, so readable by every host that has a key above.
  # to bring in sure or any other machine, add it above and in everywhere, and rekey.
  everywhere = [
    nij
    galvorn
  ];
in
{
  "eduroam.env.age".publicKeys = everywhere;
  "wifi.env.age".publicKeys = everywhere;
  "authinfo.age".publicKeys = everywhere;
  "ssh_config.age".publicKeys = everywhere;

  # per-host secrets - don't necessarily give these to `everywhere`, as `everywhere` might change.
  "tailscale.age".publicKeys = [
    nij
    galvorn
  ];
  "galvorn_backup_key.age".publicKeys = [
    nij
    galvorn
  ];
  #"sure_backup_key.age".publicKeys = [ nij sure ];
  ## At some point it'll be worth setting up wireguard access to protonvpn/nordvpn etc instead of the
  ## browser extensions, and the wireguard credentials would be encrypted by age as well
}
