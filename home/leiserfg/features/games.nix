{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  gamingPks,
  ...
}: rec {
  home.packages = with pkgs;
  with builtins;
  with lib; [
    /* wineWowPackages.staging */
    # wine-ge
    winetricks
    yuzu-early-access

    fuse-overlayfs
    dwarfs
    glslviewer
    gamingPks.wine-tkg
  ];
}
