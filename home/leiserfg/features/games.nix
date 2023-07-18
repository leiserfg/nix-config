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
    /* unstablePkgs.yuzu-early-access */
    myPkgs.yuzu
    fuse-overlayfs
    dwarfs
    glslviewer
    gamingPkgs.wine-ge
  ];
}
