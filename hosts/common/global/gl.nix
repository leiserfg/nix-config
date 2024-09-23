{
  pkgs,
  unstablePkgs,
  lib,
  inputs,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [pkgs.vulkan-validation-layers];
    # package = unstablePkgs.mesa.drivers;
    # package32 = unstablePkgs.pkgsi686Linux.mesa.drivers;
  };
}
