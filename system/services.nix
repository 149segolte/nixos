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
  );
}
