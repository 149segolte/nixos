{
  description = "NixOS flake configurations";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-25.05";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # type = [
  #   "normal" # UEFI, GPU, KDE Plasma, Home Manager, etc
  #   "qemu"   # BIOS, Minimal
  #   "rpi"    # BIOS, Minimal, tmpfs
  # ];

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      devnix = let
          custom = {
          inputs = inputs;
          name = "devnix";
          user = "one49segolte";
          system = "x86_64-linux";
          type = "normal";
        };
      in nixpkgs.lib.nixosSystem {
        system = custom.system;
          specialArgs = { inherit custom; };

        modules = [
          ./system
          ./users/base.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users."${custom.user}" =
              import ./users/home_manager.nix;
            home-manager.extraSpecialArgs = { inherit custom; };
          }
        ];
      };

      vmnix = let
        custom = {
          inputs = inputs;
          name = "nixvm";
          user = "nixos";
          system = "x86_64-linux";
          type = "qemu";
        };
      in nixpkgs.lib.nixosSystem {
        system = custom.system;
        specialArgs = { inherit custom; };
        modules = [ ./system ./users/base.nix ];
      };

      rpinix = let
        custom = {
          inputs = inputs;
          name = "rpinix";
          user = "one49segolte";
          system = "x86_64-linux";
          type = "rpi";
        };
      in nixpkgs.lib.nixosSystem {
        system = custom.system;
        specialArgs = { inherit custom; };
        modules = [ ./system ./users/base.nix ];
      };
    };
  };
}
