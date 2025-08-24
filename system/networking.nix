{ config, lib, pkgs, modulesPath, custom, ... }: {
  networking = lib.mergeAttrsList [
    {
      hostName = custom.name;
      useDHCP = true;
      nftables.enable = true;

      nameservers = [ "1.1.1.1#cloudflare-dns" "1.0.0.1#cloudflare-dns" ];

      timeServers = [
        "3.pool.ntp.org"
        "europe.pool.ntp.org"
        "asia.pool.ntp.org"
        "time.cloudflare.com"
        "time.google.com"
      ];
    }
    {
      "normal" = {
        nameservers = [ "127.0.0.1" ];
        useDHCP = false;

        interfaces = {
          enp63s0.useDHCP = true;
          wlp0s20f3.useDHCP = true;
        };

        firewall.trustedInterfaces = [ "tailscale0" ];

        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
      };
      "qemu" = { };
      "rpi" = { wireless.enable = true; };
    }."${custom.type}"
  ];
}
