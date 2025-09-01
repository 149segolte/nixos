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
      hashedPassword =
        if lib.elem "baremetal" custom.tags then
          "$y$j9T$nGliB/NCFoF/dmxMPF8Ak.$03nWUlv4WoenJsjF9Ftr85AKHGsF3rQHeXN0nFqdvWC"
        else
	  "$y$j9T$xSW9de2cqWXtlEL.U1RG80$vVdKtDxUAayDg4DFjNaoCGxKhO8fR21HVEb.Br0DKh6";
      extraGroups = [
        "wheel"
      ]
      ++ lib.optional (lib.elem "nm" custom.tags) "networkmanager"
      ++ lib.optional (lib.elem "libvirt" custom.tags) "libvirtd";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFIU5xOs/DQE3IrT8q5g6ZqGT+w2NRhlhn1n/xeYbLN one49segolte@yigirus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvyMvezBpmX5dZg1r6EpExiESWgS5BV28+7RvyvV5PL one49segolte@devnix"
      ];
    };
  };
}
