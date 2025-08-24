{ config, lib, pkgs, modulesPath, ... }: {
  # CPU
  powerManagement.cpufreq = {
    min = 800000;
    max = 3200000;
  };

  # Cross build nixos images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
