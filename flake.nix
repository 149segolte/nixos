{
  description = "NixOS flake configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-24.11";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      devnix = let
        configuration = {
          inputs = inputs;
          name = "devnix";
          user = "one49segolte";
          system = "x86_64-linux";
          uefi = true;
          minimal = false;
          gui = true;
        };
      in nixpkgs.lib.nixosSystem {
        system = configuration.system;

        specialArgs = { inherit configuration; };
        modules = [
          ./system/base.nix
          ./system/plasma.nix
          ./system/proxmox/host.nix
          ./users/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users."${configuration.user}" = import ./users/home.nix;
            home-manager.extraSpecialArgs = { inherit configuration; };
          }
        ];
      };

      nixvm = let
        configuration = {
          inputs = inputs;
          name = "nixvm";
          user = "one49segolte";
          system = "x86_64-linux";
          uefi = false;
          minimal = true;
          gui = false;
        };
      in nixpkgs.lib.nixosSystem {
        system = configuration.system;

        specialArgs = { inherit configuration; };
        modules = [
          ./system/base.nix
        ];
      };
    };
  };
}
