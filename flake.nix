{
  description = "NixOS flake configurations";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs-stable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-25.05";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations =
        nixpkgs.lib.mapAttrs
          (
            name: custom:
            nixpkgs.lib.nixosSystem {
              system = custom.system;
              specialArgs = { inherit custom inputs; };
              modules = [
                ./system
                ./users/base.nix
              ]
              ++
                nixpkgs.lib.optionals
                  (nixpkgs.lib.elem custom.name [
                    "devnix"
                  ])
                  [
                    home-manager.nixosModules.home-manager
                    {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;

                      home-manager.users."${custom.user}" = ./users/home_manager.nix;
                      home-manager.extraSpecialArgs = { inherit custom inputs; };
                    }
                  ];
            }
          )
          {
            devnix = {
              name = "devnix";
              user = "one49segolte";
              system = "x86_64-linux";
              tags = [
                "vm"
                "gui"
                "dev"
                "nm"
                "unfree"
                "tailscale"
                "gpg"
                "dnscrypt"
              ];
            };
            nixvm = {
              name = "nixvm";
              user = "nixos";
              system = "x86_64-linux";
              tags = [
                "vm"
              ];
            };
            rpinix = {
              name = "rpinix";
              user = "one49segolte";
              system = "aarch64-linux";
              tags = [
                "rpi"
		"unfree"
		"nm"
		"dnscrypt"
		"tailscale"
              ];
            };
          };
    };
}
