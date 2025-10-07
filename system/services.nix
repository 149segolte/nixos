{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  ...
}:
{
  services = lib.mergeAttrsList (
    [
      {
        zram-generator = {
          enable = true;
          settings.zram0 = { };
        };

        openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            PubkeyAuthentication = true;
          };
        };

        resolved = {
          enable = true;
          fallbackDns = [ ];
          extraConfig = "DNSStubListener=no";
        };
      }
    ]
    ++ lib.optional (lib.elem "tailscale" custom.tags) {
      tailscale.enable = true;
    }
    ++ lib.optional (lib.elem "vm" custom.tags) {
      qemuGuest.enable = true;
    }
    ++ lib.optional (lib.elem "dnscrypt" custom.tags) {
      dnscrypt-proxy2 = {
        enable = true;
        settings = {
          listen_addresses = [ "0.0.0.0:53" ];
          odoh_servers = true;
          require_dnssec = true;
          require_nolog = true;
          http3 = true;
          server_names = [
            "odoh-cloudflare"
            "odoh-crypto-sx"
          ];
          anonymized_dns.routes = [
            {
              server_name = "odoh-cloudflare";
              via = [ "odohrelay-crypto-sx" ];
            }
            {
              server_name = "odoh-crypto-sx";
              via = [ "odohrelay-ibksturm" ];
            }
          ];
          sources = {
            odoh-servers = {
              urls = [
                "https://raw.githubusercontent.com/dnscrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
              ];
              cache_file = "odoh-servers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
            };
            odoh-relays = {
              urls = [
                "https://raw.githubusercontent.com/dnscrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
                "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
              ];
              cache_file = "odoh-relays.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
            };
          };
          monitoring_ui = {
            enabled = true;
            listen_address = "127.0.0.1:5300";
            username = "";
            password = "";
            enable_query_log = true;
          };
        };
      };
    }
    ++ lib.optional (lib.elem "hostapd" custom.tags) {
      hostapd = {
        enable = true;
        radios = lib.mkIf (lib.elem "rpi" custom.tags) {
          "wlp1s0u1u3" = {
            countryCode = "US";
            band = "5g";
            channel = 149;
            settings = {
              wds_sta = true;
              vht_oper_centr_freq_seg0_idx = 155;
            };
            networks."wlp1s0u1u3" = {
              ssid = "rpiout";
              authentication.saePasswords = [ { password = ""; } ]; # TODO: set before use
            };
            wifi4 = {
              enable = true;
              capabilities = [
                "HT40+"
                "SHORT-GI-20"
                "SHORT-GI-40"
                "RX-STBC1"
                "MAX-AMSDU-7935"
                "DSSS_CCK-40"
              ];
            };
            wifi5 = {
              enable = true;
              capabilities = [
                "MAX-MPDU-11454"
                "SHORT-GI-80"
                "SU-BEAMFORMEE"
                "HTC-VHT"
                "TX-STBC-2BY1"
              ];
              operatingChannelWidth = "80";
            };
          };
        };
      };
    }
    ++ lib.optional (lib.elem "ntpd" custom.tags) {
      ntpd-rs = {
        enable = true;
        useNetworkingTimeServers = false;
        settings = {
          server = [
            {
              allowlist = {
                action = "ignore";
                filter = [
                  "172.19.149.0/24"
                  "127.0.0.1/32"
                ];
              };
              listen = "0.0.0.0:123";
            }
          ];
          source = [
            {
              address = "3.pool.ntp.org";
              mode = "server";
            }
            {
              address = "europe.pool.ntp.org";
              count = 2;
              mode = "pool";
            }
            {
              address = "asia.pool.ntp.org";
              count = 2;
              mode = "pool";
            }
            {
              address = "time.cloudflare.com";
              mode = "server";
            }
            {
              address = "time.google.com";
              mode = "server";
            }
          ];
        };
      };
    }
    ++ lib.optional (lib.elem "kea" custom.tags) {
      kea.dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = lib.mkIf (lib.elem "rpi" custom.tags) [
              "wlp1s0u1u3"
            ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;
          option-data = [
            {
              name = "routers";
              code = 3;
              space = "dhcp4";
              data = "172.19.149.1";
            }
            {
              name = "domain-name";
              code = 15;
              space = "dhcp4";
              data = "segolte.arpa";
            }
            {
              name = "domain-name-servers";
              code = 6;
              space = "dhcp4";
              data = "172.19.149.1";
              always-send = true;
            }
            {
              name = "ntp-servers";
              code = 42;
              space = "dhcp4";
              data = "172.19.149.1";
              always-send = true;
            }
          ];
          subnet4 = [
            {
              id = 1;
              pools = [
                {
                  pool = "172.19.149.10 - 172.19.149.240";
                }
              ];
              subnet = "172.19.149.0/24";
            }
          ];
        };
      };
    }
  );
}
