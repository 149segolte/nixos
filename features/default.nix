{
  config,
  lib,
  pkgs,
  custom,
  ...
}:
{
  imports = [
    ./network-manager.nix
  ];

  config.features = custom.features;
}
