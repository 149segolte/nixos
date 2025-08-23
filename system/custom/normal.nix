{ config, lib, pkgs, variables, ... }: {
  # Bootloader
  boot.loader.efi.canTouchEfiVariables = lib.mkForce true;

  # Cross build nixos images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkForce true;

  # Enable networking
  networking.networkmanager.enable = lib.mkForce true;
  networking.firewall.trustedInterfaces = [ "incusbr0" "tailscale0" ];
  services.resolved = {
    enable = true;
    domains = [ "~." ];
    dnssec = "true";
  };
  networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];

  # Incus
  virtualisation.incus.enable = true;
  environment.systemPackages = with pkgs; [ incus-ui-canonical distrobuilder ];

  # Tailscale
  services.tailscale.enable = true;
  networking.interfaces."tailscale0".useDHCP = lib.mkForce false;

  # Hardware configuration
  boot.initrd.availableKernelModules = [
    "sd_mod" "ahci" "xhci_pci" "nvme" "usbhid" "usb_storage" 
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
