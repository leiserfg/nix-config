{ pkgs, ... }:

pkgs.buildNpmPackage {
  dontNpmBuild = true;
  pname = "brave-search";
  version = "1.0.0";

  src = ./.;
  npmDeps = pkgs.importNpmLock { npmRoot = ./.; };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;


  meta = with pkgs.lib; {
    description = "Brave web search and readable content extractor CLI tool";
    license = licenses.mit;
    mainProgram = "brave-search";
  };
}
