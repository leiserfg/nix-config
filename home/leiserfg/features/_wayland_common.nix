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
}
