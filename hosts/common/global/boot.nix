{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
