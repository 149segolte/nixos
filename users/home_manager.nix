{
  config,
  lib,
  pkgs,
  custom,
  ...
}:
{
  home.username = custom.user;
  home.homeDirectory = "/home/${custom.user}";
  # home.shell.enableShellIntegration = true;

  home.packages =
    with pkgs;
    [
      dust
      fd
      fzf
      gh
      nushell
    ]
    ++ lib.optionals (lib.elem "gui" custom.tags) [
      google-chrome
      copyq
      zed-editor
      spotify
      vscode
    ];

  programs.ghostty = lib.mkIf (lib.elem "gui" custom.tags) {
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
    plugins = with pkgs.fishPlugins; [
      {
        name = "tide";
        src = tide.src;
      }
      {
        name = "fzf-fish";
        src = fzf-fish.src;
      }
    ];
  };

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
