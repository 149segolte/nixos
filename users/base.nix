{ config, lib, pkgs, variables, ... }: {
  environment.localBinInPath = true;

  users = {
    users."${variables.user}" = {
      isNormalUser = true;
      linger = true;
      extraGroups = [ "incus-admin" "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJDftX2Fu1EzN9S1hO8LMjBG3qepW+kH7TgD33Dx/d2 one49segolte@yigirus.local"
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6USZNyBDAhWgKzTo17wcYwt/FcucOf2z1F0kewJksA one49segolte@devnix"
      ];
    };
  };
}
