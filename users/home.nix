{ config, lib, pkgs, configuration, ... }: {
  home.username = configuration.user;
  home.homeDirectory = "/home/${configuration.user}";
  # home.shell.enableShellIntegration = true;

  home.packages = with pkgs; [
    fish wget bc file which neovim tree
  ] ++ lib.optionals (configuration.minimal == false) [
    devenv aria2 nmap ripgrep eza fzf libqalculate
  ] ++ lib.optionals (configuration.gui == true) [
    google-chrome
  ];

  programs.bash.enable = true;
    
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      theme = "tokyonight";
      command = "bash -c 'fish'";
      background-opacity = 0.9;
    };
  };

  # Services
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  # link all files in `./bin` to `~/.local/bin/`
  home.file."./.local/bin" = {
    source = ./bin;
    recursive = true;
    executable = true;
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
