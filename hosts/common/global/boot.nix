{pkgs, unstablePkgs, ...}: {
  boot = {
    kernelPackages = unstablePkgs.linuxPackages_latest;
    # kernelPackages = unstablePkgs.linuxPackages_xanmod_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = ["hid-nintendo"];
  };
}
