{ config, lib, pkgs, variables, ... }: {
  # System defaults
  networking.hostName = variables.name;
  time.timeZone = "America/New_York";
  environment.enableAllTerminfo = true;
  users.mutableUsers = false;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Nix settings
  nix = {
    registry.nixpkgs.flake = variables.inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "${variables.user}" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  programs.git.enable = true;
  programs.less.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Enable services
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

  system.stateVersion = "25.05";
}

