{pkgs, ...}: {
  imports = [./common.nix ./features/games.nix];
  home.packages = with pkgs; [
    steam-run
    steam
    ansel
    ventoy-bin
    blender_3_4
    (luajit.withPackages (ps: with ps; [fennel]))
    gource
    davinci-resolve
   audacity
   abiword
  ];
  }
