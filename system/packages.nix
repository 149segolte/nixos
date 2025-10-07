{
  config,
  lib,
  pkgs,
  modulesPath,
  custom,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      # Ensure anyways
      bash
      coreutils
      findutils
      gnused
      pciutils
      usbutils
      util-linux
    ]
    ++ [
      # Basics
      file
      which
      gnutar
      wget
      curl
      python3
    ]
    ++ [
      # Tools
      ripgrep
      btop
      eza
      iw
    ];

  programs = lib.mergeAttrsList (
    [
      {
        less.enable = true;
        bat.enable = true;
        zoxide.enable = true;
        nix-ld.enable = true;
        direnv.enable = true;

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
          shellAbbrs = {
            ll = "ls -la";
          };
        };
      }
    ]
    ++ lib.optional (lib.elem "libvirt" custom.tags) {
      virt-manager.enable = true;
    }
    ++ lib.optional (lib.elem "gui" custom.tags) {
      localsend = {
        enable = true;
        openFirewall = true;
      };

      appimage = {
        enable = true;
        binfmt = true;
      };
    }
    ++ lib.optional (lib.elem "gpg" custom.tags) {
      gnupg = {
        package = pkgs.gnupg1;
        agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };
    }
  );
}
