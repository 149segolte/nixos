{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  ...
}:
{
  networking = lib.mergeAttrsList (
    [
      {
        hostName = custom.name;
        useDHCP = lib.mkDefault true;
        nftables.enable = true;

        nameservers = [
          "1.1.1.1#cloudflare-dns"
          "1.0.0.1#cloudflare-dns"
        ];

        timeServers = [
          "3.pool.ntp.org"
          "europe.pool.ntp.org"
          "asia.pool.ntp.org"
          "time.cloudflare.com"
          "time.google.com"
        ];

        firewall.trustedInterfaces = lib.mkIf (lib.elem "tailscale" custom.tags) [ "tailscale0" ];
      }
    ]
    ++ lib.optional (lib.elem "wpa_supplicant" custom.tags) {
      wireless.enable = true;
    }
    ++ lib.optional (lib.elem "ntpd" custom.tags) {
      timeServers = [ "127.0.0.1" ];
    }
    ++ lib.optional (lib.elem "nm" custom.tags) {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.powersave = !(lib.elem "rpi" custom.tags);
        ensureProfiles.profiles."rpiin" = lib.mkIf (lib.elem "rpi" custom.tags) {
          connection = {
            id = "rpiin";
            type = "wifi";
            interface-name = "wlan0";
            autoconnect = "true";
          };
          wifi = {
            bssid = ""; # 5GHz BSSID from `iw wlan0 scan`
            mode = "infrastructure";
            ssid = ""; # `iw wlan0 scan`
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "";
          };
          ipv4 = {
            method = "auto";
          };
        };
        unmanaged = lib.mkIf (lib.elem "rpi" custom.tags) [ "wlp1s0u1u1" ];
      };
    }
    ++ lib.optional (lib.elem "dnscrypt" custom.tags) {
      nameservers = [ "127.0.0.1" ];
    }
    ++ lib.optional (lib.elem "rpi" custom.tags) {
      interfaces."wlp1s0u1u1".ipv4.addresses = [
        {
          address = "172.19.149.1";
          prefixLength = 24;
        }
      ];
    }
    ++ lib.optional (lib.elem "baremetal" custom.tags) {
      useDHCP = false;
      interfaces = {
        enp63s0.useDHCP = true;
        wlp0s20f3.useDHCP = true;
      };
    }
  );

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf (lib.elem "rpi" custom.tags) 1;
}
