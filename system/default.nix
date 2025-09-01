{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./packages.nix
    ./services.nix
    ./networking.nix
    ./hardware.nix
    ./custom.nix
  ]
  ++ lib.optional (lib.elem "gui" custom.tags) ./plasma.nix
  ++ lib.optional (lib.elem "vm" custom.tags) (modulesPath + "/profiles/qemu-guest.nix");

  # System defaults
  time.timeZone = custom.timezone or "America/New_York";
  environment.enableAllTerminfo = true;
  users.mutableUsers = false;

  # Locale
  i18n.defaultLocale = custom.locale or "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = custom.locale or "en_US.UTF-8";
    LC_IDENTIFICATION = custom.locale or "en_US.UTF-8";
    LC_MEASUREMENT = custom.locale or "en_IN"; # Metric
    LC_MONETARY = custom.locale or "en_US.UTF-8";
    LC_NAME = custom.locale or "en_US.UTF-8";
    LC_NUMERIC = custom.locale or "en_US.UTF-8";
    LC_PAPER = custom.locale or "en_IN"; # A4
    LC_TELEPHONE = custom.locale or "en_US.UTF-8";
    LC_TIME = custom.locale or "en_US.UTF-8";
  };

  # Nix
  nixpkgs.config.allowUnfree = (lib.elem "unfree" custom.tags);
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "${custom.user}" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
