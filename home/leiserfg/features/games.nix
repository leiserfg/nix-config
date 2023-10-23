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
    # wine-ge
    winetricks
    # unstablePkgs.yuzu-early-access
    # unstablePkgs.ryujinx
    myPkgs.yuzu
    mgba
    aseprite
    fuse-overlayfs
    dwarfs
    glslviewer
    gamingPkgs.wine-ge
  ];
}
