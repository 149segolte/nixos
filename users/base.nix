{
  config,
  lib,
  pkgs,
  custom,
  ...
}:
{
  environment.localBinInPath = true;

  users = {
    users."${custom.user}" = {
      isNormalUser = true;
      linger = true;
      hashedPassword = "$6$owCyjSRvrhb4BqHV$ZSXv9Ui0JaWb.9k5TW11AlsNabe4u4I8kFhL7javAzRX/dDgEiy9XmXLlp4y7kqDHaBGi.mRRZqXzfm/6Gc/G1";
      extraGroups = [
        "wheel"
      ]
      ++ lib.optionals (custom.type == "normal") [
        "networkmanager"
        "libvirtd"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFIU5xOs/DQE3IrT8q5g6ZqGT+w2NRhlhn1n/xeYbLN one49segolte@yigirus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6USZNyBDAhWgKzTo17wcYwt/FcucOf2z1F0kewJksA one49segolte@devnix"
      ];
    };
  };
}
