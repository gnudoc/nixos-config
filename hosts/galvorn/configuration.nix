{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/boot.nix
    ../../common/system/networking.nix
    ../../common/system/desktop.nix
    ../../common/system/security.nix
    ../../common/system/nix.nix
    ../../common/system/core.nix
  ];

  networking.hostName = "galvorn";

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = "/root/secrets/galvorn_tailscale_key";
    extraUpFlags = [
      "--exit-node=100.84.16.46"
      "--exit-node-allow-lan-access=true"
      "--operator=nij"
    ];
  };

  age.secrets = {
    eduroam.file = ../../secrets/eduroam.env.age;
    wifi.file = ../../secrets/wifi.env.age;
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.age.secrets.eduroam.path
      config.age.secrets.wifi.path
    ];
    profiles = {
      home-wifi = {
        connection = {
          id = "home-wifi";
          type = "wifi";
        };
        wifi = {
          ssid = "GL-MT6000-5b7";
        };
        wifi-sec = {
          key-mgmt = "wpa-psk";
          psk = "$HOME_WIFI_PASSWORD";
        };
      };
      pixel-hotspot = {
        connection = {
          id = "pixel-hotspot";
          type = "wifi";
        };
        wifi = {
          ssid = "Moth";
        };
        wifi-sec = {
          key-mgmt = "wpa-psk";
          psk = "$PIXEL_HOTSPOT_PASSWORD";
        };
      };
      eduroam = {
        connection = {
          id = "eduroam";
          type = "wifi";
          interface-name = "wlp1s0";
        };
        wifi = {
          ssid = "eduroam";
        };
        wifi-sec = {
          key-mgmt = "wpa-eap";
        };
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
}
