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
    winetricks
    yuzu-early-access
    godot
  ];
}
