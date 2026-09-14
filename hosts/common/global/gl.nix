{
  pkgs,
  lib,
  inputs,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [pkgs.vulkan-validation-layers];
  };
}
