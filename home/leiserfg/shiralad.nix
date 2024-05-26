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
    ./features/x11.nix
  ];

   home.packages = with pkgs; [
tmux
docker

   ];
}
