{ pkgs, config, ... }:
let
  # A WPA-Personal wifi profile. `psk` is not the password but the name of a
  # variable ("$NAME") from the agenix-encrypted environment files below;
  # NetworkManager-ensure-profiles substitutes the real value at boot, so the
  # password never lands in the world-readable Nix store.
  wpaPsk = id: ssid: psk: {
    connection = {
      inherit id;
      type = "wifi";
    };
    wifi = { inherit ssid; };
    wifi-security = {
      key-mgmt = "wpa-psk";
      inherit psk;
    };
  };
in
{
  environment.systemPackages = [ pkgs.dnsutils ];

  age.secrets = {
    eduroam.file = ../../secrets/eduroam.env.age;
    wifi.file = ../../secrets/wifi.env.age;
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [
        config.age.secrets.eduroam.path
        config.age.secrets.wifi.path
      ];
      profiles = {
        home-wifi = wpaPsk "home-wifi" "GL-MT6000-5b7" "$HOME_WIFI_PASSWORD";
        pixel-hotspot = wpaPsk "pixel-hotspot" "Moth" "$PIXEL_HOTSPOT_PASSWORD";
        eduroam = {
          connection = {
            id = "eduroam";
            type = "wifi";
          };
          wifi.ssid = "eduroam";
          wifi-security.key-mgmt = "wpa-eap";
          "802-1x" = {
            eap = "peap";
            phase2-auth = "mschapv2";
            identity = "aijaz.mohammad@ou.ac.uk";
            password = "$EDUROAM_PASSWORD";
            domain-suffix-match = "eduroam.ou.ac.uk";
          };
        };
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # loosens rp_filter, needed to use an exit node
  };
}
