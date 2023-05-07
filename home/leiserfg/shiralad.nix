{
  pkgs,
  unstablePkgs,
  myPkgs,
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
    myPkgs.ansel
    ventoy-bin
    blender_3_5
    unstablePkgs.godot_4
    rink
    /*
    davinci-resolve
    */
    /*
    audacity
    */
    /*
    abiword
    */
    tree-sitter
    nmap
    libclang
  ];
}
