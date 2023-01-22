{pkgs, ...}: {
  imports = [./common.nix ./features/games.nix];
  home.packages = with pkgs; [
    steam-run
    (luajit.withPackages (ps: with ps; [fennel]))
    # gnome.simple-scan
  ];
}
