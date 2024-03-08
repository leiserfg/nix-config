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
    myPkgs.yuzu-early-access
    # unstablePkgs.ryujinx
    # mgba
    # aseprite
    fuse-overlayfs
    dwarfs
    bubblewrap
    # glslviewer
    # dxvk
    gamingPkgs.wine-tkg  # This one has the wayland patches
    # gamingPkgs.wine-ge
    # wineWowPackages.waylandFull
    myPkgs.glslviewer
  ];
}
