{
  pkgs,
  unstablePkgs,
  inputs,
  myPkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./features/games.nix
    ./features/wayland.nix
  ];
  # home.packages = with pkgs; [];
}
