{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.network-manager;
in
{
  options.features.network-manager = {
    enable = mkEnableOption "configure and use NetworkManager";

    wifi_powersave = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wi-Fi power saving mode";
    };

    wifis = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            ssid = mkOption {
              type = types.str;
              description = "WiFi network SSID";
            };
            psk = mkOption {
              type = types.str;
              description = "WiFi network password";
            };
            bssid = mkOption {
              type = types.str;
              description = "WiFi network BSSID";
            };
            interface_name = mkOption {
              type = types.str;
              description = "Network interface name";
            };
          };
        }
      );
      default = [ ];
      description = ''
        List of Wi-Fi networks to connect to.
      '';
    };

    unmanaged = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of interfaces that will not be managed by NetworkManager.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      wifi.powersave = cfg.wifi_powersave;
      ensureProfiles.profiles = mergeAttrsList (
        map (wifi: {
          "${wifi.ssid}" = {
            connection = {
              id = wifi.ssid;
              type = "wifi";
              interface-name = wifi.interface_name;
              autoconnect = "true";
            };
            wifi = {
              bssid = wifi.bssid;
              mode = "infrastructure";
              ssid = wifi.ssid;
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = wifi.psk;
            };
            ipv4 = {
              method = "auto";
            };
          };
        }) cfg.wifis
      );
      unmanaged = cfg.unmanaged;
    };
  };
}
