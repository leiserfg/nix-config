{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  gamingPkgs,
  unstablePkgs,
  myPkgs,
  ...
}: rec {
  home.packages = with pkgs;
  with builtins;
  with lib; [
    /* wineWowPackages.staging */
    winetricks
    unstablePkgs.yuzu-early-access
    # unstablePkgs.ryujinx
    # mgba
    # aseprite
    fuse-overlayfs
    dwarfs
    # glslviewer
    # gamingPkgs.wine-tkg  # This one has the wayland patches
    # dxvk
    gamingPkgs.wine-ge
    # wineWowPackages.waylandFull
  ];
}
