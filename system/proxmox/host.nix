{ config, lib, pkgs, modulesPath, configuration, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nvidia.nix
  ];

  # Packages for system management
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = if (configuration.uefi == true) then true else false;
  boot.loader.efi.canTouchEfiVariables = if (configuration.uefi == true) then true else false;

  # Hardware configuration
  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault configuration.system;
}
