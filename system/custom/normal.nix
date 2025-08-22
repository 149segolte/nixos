{ config, lib, pkgs, variables, ... }: {
  # Bootloader
  boot.loader.efi.canTouchEfiVariables = lib.mkForce true;

  # Cross build nixos images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkForce true;

  # Enable networking
  networking.networkmanager.enable = lib.mkForce true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = lib.mkForce true;

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
