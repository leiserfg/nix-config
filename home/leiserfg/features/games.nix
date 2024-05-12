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
    unstablePkgs.wineWowPackages.staging
    winetricks
    myPkgs.yuzu-early-access
    # unstablePkgs.ryujinx
    # mgba
    # aseprite
    fuse-overlayfs
    dwarfs
    bubblewrap
    # glslviewer
    # unstablePkgs.dxvk.bin
    # gamingPkgs.wine-tkg  # This one has the wayland patches
    # gamingPkgs.wine-ge
    # unstablePkgs.wineWowPackages.waylandFull
    myPkgs.glslviewer
  ];
}
