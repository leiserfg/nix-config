{
  pkgs,
  unstablePkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    wev
    wl-clipboard
    wdisplays
  ];
  programs.rofi.package = pkgs.rofi-wayland;
}
