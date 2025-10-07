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

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
      ref = "main";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nix-diff
          ];
        };
      }
    )
    // {
      nixosConfigurations =
        builtins.mapAttrs
          (
            name: custom:
            nixpkgs.lib.nixosSystem {
              system = custom.system;
              specialArgs = { inherit custom inputs; };
              modules = [
                ./system
                ./users/base.nix
                ./features
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
              features = { };
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
              features = { };
              tags = [
                "vm"
              ];
            };
            rpinix = {
              name = "rpinix";
              user = "one49segolte";
              system = "aarch64-linux";
              features = {
                network-manager = {
                  enable = true;
                  wifi_powersave = false;
                  wifis = [
                    {
                      ssid = "SETUP-7046"; # `iw wlan0 scan`
                      psk = "creak2151common";
                      bssid = "08:a7:c0:03:70:52"; # 5GHz BSSID from `iw wlan0 scan`
                      interface_name = "wlan0";
                    }
                  ];
                };
              };
              tags = [
                "rpi"
                "unfree"
                "nm"
                "dnscrypt"
                "tailscale"
                "hostapd"
                "ntpd"
                "kea"
              ];
            };
          };
    };
}
