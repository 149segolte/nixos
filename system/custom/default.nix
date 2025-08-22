{ config, lib, pkgs, modulesPath, variables, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ lib.optionals (variables.type == "normal") [
    ./normal.nix
    ../plasma.nix
  ] ++ lib.optionals (variables.type == "qemu") [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./qemu.nix
  ] ++ lib.optionals (variables.type == "rpi") [
    ./rpi.nix
  ] ++ lib.optionals (false) [ # Disabled imports
    ../nvidia.nix
  ];

  # Bootloader
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;

  # Packages
  environment.systemPackages = with pkgs; [ curl btop btrfs-progs fish wget file which tree ];

  # Firewall
  networking.nftables.enable = lib.mkDefault true;
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 80 443 ];
    # allowedUDPPortRanges = [
    #   { from = 4000; to = 4007; }
    #   { from = 8000; to = 8010; }
    # ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp63s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault variables.system;
}
