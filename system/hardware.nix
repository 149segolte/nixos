{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  ...
}:
{
  # Bootloader
  boot.loader = lib.mergeAttrsList (
    [
      {
        grub.enable = false;
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 10;
      }
    ]
    ++ lib.optional (lib.elem "uefi" custom.tags) {
      efi.canTouchEfiVariables = true;
    }
    ++ lib.optional (lib.elem "rpi" custom.tags) {
      systemd-boot.enable = false;
      generic-extlinux-compatible.enable = true;
    }
  );

  # Kernel
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
    "usb_storage"
  ]
  ++ lib.optionals (lib.elem "baremetal" custom.tags) [
    "sd_mod"
    "ahci"
    "nvme"
  ]
  ++ lib.optionals (lib.elem "vm" custom.tags) [
    "sd_mod"
    "ahci"
    "uhci_hcd"
    "ehci_pci"
    "sr_mod"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = lib.mkIf (lib.elem "baremetal" custom.tags) [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Filesystems
  swapDevices = [ ];

  fileSystems = lib.mergeAttrsList (
    [ ]
    ++ lib.optional (!lib.elem "rpi" custom.tags) {
      "/" = {
        device = "/dev/disk/by-label/root";
        fsType = "btrfs";
        options = [
          "compress=zstd"
        ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    }
    ++ lib.optional (lib.elem "rpi" custom.tags) {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };
    }
    ++ lib.optional (lib.elem "extra1" custom.tags) {
      "/mnt/data" = {
        device = "/dev/disk/by-label/extra1";
        fsType = "btrfs";
        options = [
          "subvol=/"
          "compress=zstd"
        ];
      };
    }
  );

  # Extra flags
  hardware.cpu.intel.updateMicrocode = lib.mkIf (lib.elem "baremetal" custom.tags) (
    lib.mkDefault config.hardware.enableRedistributableFirmware
  );
}
