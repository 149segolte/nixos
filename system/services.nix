{ config, lib, pkgs, modulesPath, custom, ... }: {
  services = lib.mergeAttrsList [
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
    {
      "normal" = {
        aria2.enable = true;
        tailscale.enable = true;

        dnscrypt-proxy2 = {
          enable = true;
          settings = {
                        odoh_servers = true;
            require_dnssec = true;
            require_nolog = true;
            http3 = true;
            server_names = [ "odoh-cloudflare" "odoh-crypto-sx" ];
          };
        };
      };
      "qemu" = { qemuGuest.enable = true; };
      "rpi" = { };
    }."${custom.type}"
  ];
}
