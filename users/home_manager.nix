{ config, lib, pkgs, variables, ... }: {
  home.username = variables.user;
  home.homeDirectory = "/home/${variables.user}";
  # home.shell.enableShellIntegration = true;

  home.packages = with pkgs; [ ] ++ lib.optionals (variables.type == "normal") [
    aria2 bat dust eza fd fzf gh nushell ripgrep zoxide
    google-chrome copyq zed-editor localsend spotify tailscale vscode
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "tokyonight";
      command = "fish";
      background-opacity = 0.9;
      font-size = 15;
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v6";
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "main";
        };
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
