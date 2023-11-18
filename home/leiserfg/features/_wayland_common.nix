{
  pkgs,
  unstablePkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    rofi-wayland
    wev
    wl-clipboard
    wdisplays
  ];
}
