{pkgs, ...}:
{
  imports = [./common.nix ./features/games.nix];
  home.packages  = [pkgs.steam-run
    ( pkgs.luajit.withPackages (ps: with ps; [fennel]) )

  ];
}
