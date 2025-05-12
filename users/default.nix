{ config, lib, pkgs, configuration, ... }: {
  environment.localBinInPath = true;

  users = {
    mutableUsers = false;
    users."${configuration.user}" = {
      isNormalUser = true;
      linger = true;
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$zAkXwKcHRJLXs074fo01x.$ESVXcHqgvRrVr3smXJSAz42z9InjI8sPQyV877VmHNC";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJDftX2Fu1EzN9S1hO8LMjBG3qepW+kH7TgD33Dx/d2 one49segolte@yigirus.local"
      ];
    };
  };
}
