{pkgs, ...}:
{
  imports = [./common.nix ./features/games.nix];
  home.packages  = [pkgs.steam-run];
}
