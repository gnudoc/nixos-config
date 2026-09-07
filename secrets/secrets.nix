let
  nij = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApyurZoUj76OOFA3jAhorJ+89hs9iL10n+txEJb0gR8 nij@galvorn";
  galvorn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN51R854jRP+1zjkrph745TcT+29h4+VNL65yqVP9ODS root@galvorn";
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
}
