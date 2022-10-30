{
  pkgs,
  lib,
  inputs,
  ...
}: {
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
}
