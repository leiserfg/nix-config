{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./features/games.nix
    /*
    ./features/daw.nix
    */
  ];
  home.packages = with pkgs; [
 unstablePkgs.steam-run
    unstablePkgs.steam
    ansel
    ventoy-bin
    blender_3_4
    unstablePkgs.godot_4
    rink
    davinci-resolve
    audacity
    /* abiword */
    tree-sitter
    nmap

  ];
}
