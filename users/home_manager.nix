{ config, lib, pkgs, custom, ... }: {
  home.username = custom.user;
  home.homeDirectory = "/home/${custom.user}";
  # home.shell.enableShellIntegration = true;

  home.packages = with pkgs;
    [ ] ++ lib.optionals (custom.type == "normal") [
      aria2
      bat
      dust
      eza
      fd
      fzf
      gh
      nushell
      ripgrep
      zoxide
      google-chrome
      copyq
      zed-editor
      localsend
      spotify
      vscode
    ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "tokyonight";
      command = "fish";
      background-opacity = 0.9;
      font-size = 12;
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
    shellAliases = {
      cat = "bat";
      cd = "z";
      grep = "rg";
      ls = "eza";
      ll = "eza -la";
    };
    shellInitLast = "zoxide init fish | source";
  };

  # Services
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  # # link all files in `./bin` to `~/.local/bin/`
  # home.file."./.local/bin" = {
  #   source = ./bin;
  #   recursive = true;
  #   executable = true;
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
