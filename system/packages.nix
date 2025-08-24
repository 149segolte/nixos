{ config, lib, pkgs, modulesPath, custom, ... }: {
  environment.systemPackages = with pkgs;
    [ # Ensure anyways
      bash
      coreutils
      findutils
      gnused
      pciutils
      usbutils
      util-linux
    ] ++ [ # Basics
      file
      which
      gnutar
      wget
      curl
      python3
    ] ++ [ # Tools
      ripgrep
      btop
      eza
    ];

  programs = lib.mergeAttrsList [
    {
      less.enable = true;
      bat.enable = true;
      zoxide.enable = true;

      git = {
        enable = true;
        config = {
          init.defaultBranch = "main";
          commit.gpgSign = true;
          tag.gpgSign = true;
          gpg.format = "ssh";
        };
      };

      tmux = {
        enable = true;
        clock24 = true;
      };

      neovim = {
        enable = true;
        defaultEditor = true;
      };

      fish = {
        enable = true;
        shellAliases = {
          ls = "eza";
          grep = "rg";
          cat = "bat";
          cd = "z";
        };
        shellAbbrs = { ll = "ls -la"; };
      };
    }
    {
      "normal" = {
        gnupg = {
          package = pkgs.gnupg1;
          agent = {
            enable = true;
            enableSSHSupport = true;
          };
        };

        localsend = {
          enable = true;
          openFirewall = true;
        };

        appimage = {
          enable = true;
          binfmt = true;
        };
      };
      "qemu" = { };
      "rpi" = { };
    }."${custom.type}"
  ];
}
