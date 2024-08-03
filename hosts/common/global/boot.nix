{
  pkgs,
  unstablePkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_6_9; # amdgpu in 6.10 is brocken
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = ["hid-nintendo"];
  };
}
