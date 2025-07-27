{
  pkgs,
  config,
  ...
}:
{
  boot = {
    # kernelPackages = pkgs.linuxPackages_6_12;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [
      "hid-nintendo"
      "k10temp"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ zenpower ];

  };
}
