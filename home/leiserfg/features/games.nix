{
  inputs,
  lib,
  pkgs,
  config,
  outputs,

  unstablePkgs,
  myPkgs,
  ...
}:
rec {
  home.packages =
    with pkgs;
    with builtins;
    with lib;
    [
      # wineWowPackages.staging
      winetricks
      myPkgs.eden-emu
      # unstablePkgs.ryujinx
      # mgba
      # aseprite
      fuse-overlayfs
      dwarfs
      bubblewrap
      umu-launcher
      # glslviewer
      # dxvk.out

      # gamingPkgs.wine-ge
      # unstablePkgs.wineWowPackages.waylandFull
      # myPkgs.glslviewer
    ];
}
