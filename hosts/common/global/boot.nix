{pkgs, ...}: {
  boot = {
    # BOOT partition is defined in fs.nix
    kernelPackages = pkgs.linuxPackages_xanmod;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
