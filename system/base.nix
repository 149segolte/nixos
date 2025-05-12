{ config, lib, pkgs, configuration, ... }: {
  # System defaults
  networking.hostName = configuration.name;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  environment.enableAllTerminfo = true;

  # Nix settings
  nix = {
    registry.nixpkgs.flake = configuration.inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "${configuration.user}" ];
    };
  };

  # Base packages
  environment.systemPackages = with pkgs; [
    curl btop python3
  ];

  programs.git.enable = true;
  programs.less.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  # Enable services

  services.qemuGuest.enable = true;

  services.zram-generator = {
    enable = true;
    settings.zram0 = {};
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "24.11";
}

