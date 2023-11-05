{pkgs, unstablePkgs, ...}: {
  boot = {
    kernelPackages = unstablePkgs.linuxPackages_6_6;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = ["hid-nintendo"];
  };
}
