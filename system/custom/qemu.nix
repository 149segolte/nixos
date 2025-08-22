{ config, lib, pkgs, variables, ... }: {
  # QEMU guest agent
  services.qemuGuest.enable = true;

  # Hardware configuration
  boot.initrd.availableKernelModules = [
    "sd_mod" "ahci" "uhci_hcd" "ehci_pci" "virtio_pci" "virtio_scsi" "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
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
}
