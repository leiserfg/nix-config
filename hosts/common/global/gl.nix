{
  pkgs,
  unstablePkgs,
  lib,
  inputs,
  ...
}: {
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = [pkgs.vulkan-validation-layers];
    # package = unstablePkgs.mesa.drivers;
    # package32 = unstablePkgs.pkgsi686Linux.mesa.drivers;
  };
}
