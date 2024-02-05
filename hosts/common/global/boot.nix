{pkgs, unstablePkgs, ...}: {
  boot = {
    kernelPackages = unstablePkgs.linuxPackages_6_6;
    # kernelPackages = unstablePkgs.linuxPackages_xanmod_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = ["hid-nintendo"];
  };
}
