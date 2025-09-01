{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  ...
}:
{
  # CPU
  powerManagement.cpufreq = lib.mkIf (lib.elem "baremetal" custom.tags) {
    min = 800000;
    max = 3200000;
  };

  # Cross build nixos images
  boot.binfmt.emulatedSystems = lib.mkIf (lib.elem "dev" custom.tags) [ "aarch64-linux" ];

  # Virtualization
  virtualisation = lib.mkIf (lib.elem "libvirt" custom.tags) {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
      };
    };
  };
}
