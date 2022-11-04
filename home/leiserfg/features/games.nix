{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: rec {
  home.packages = with pkgs;
  with builtins;
  with lib; [
    wineWowPackages.staging
    # wine-ge
    winetricks
    yuzu-early-access
    dwarfs
    godot

    glslviewer
  ];
}
