{ config, lib, pkgs, modulesPath, custom, ... }: {
  # Bootloader
  boot.loader = lib.mergeAttrsList [
    {
      grub.enable = false;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
    }
    {
      "normal" = { efi.canTouchEfiVariables = true; };
      "qemu" = { };
      "rpi" = {
        systemd-boot.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    }."${custom.type}"
  ];

  # Kernel
  boot.initrd.availableKernelModules = {
    "normal" = [ "sd_mod" "ahci" "xhci_pci" "nvme" "usbhid" "usb_storage" ];
    "qemu" = [ "sd_mod" "ahci" "uhci_hcd" "ehci_pci" "sr_mod" ];
    "rpi" = [ "xhci_pci" "usbhid" "usb_storage" ];
  }."${custom.type}";
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = lib.mkIf (custom.type == "normal") [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Filesystems
  swapDevices = [ ];

  fileSystems = lib.mergeAttrsList [
    {
      "/" = {
        device = "/dev/disk/by-label/root";
        fsType = "btrfs";
        options = [ "subvol=@" "compress=zstd" ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
    }
    {
      "normal" = {
        "/mnt/data" = {
          device = "/dev/disk/by-label/extra1";
          fsType = "btrfs";
          options = [ "subvol=/" "compress=zstd" ];
        };
      };
      "qemu" = { };
      "rpi" = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
          options = [ "noatime" ];
        };
        "/boot" = null;
      };
    }."${custom.type}"
  ];

  # Extra flags
  hardware.cpu.intel.updateMicrocode = lib.mkIf (custom.type == "normal")
    (lib.mkDefault config.hardware.enableRedistributableFirmware);
}
