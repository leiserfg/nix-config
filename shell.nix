{
  pkgs ?
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/63dacb46bf939521bdc93981b4cbb7ecb58427a0.tar.gz";
    }) {},
}: let
  projectRoot = "${builtins.toString ./.}/src/inventorum.api";
in
  pkgs.mkShell {
    buildInputs = [

      pkgs.python312
      pkgs.python312Packages.pip
    ];
    shellHook = ''
    '';
  }
