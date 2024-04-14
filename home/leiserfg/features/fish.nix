{unstablePkgs, ...}: {
  programs.fish = {
    enable = true;
    package = unstablePkgs.fish;
    interactiveShellInit = ''
    '';
    shellAliases = {
    };
  };
  programs.zoxide = {
    enable = true;
  };
  programs.starship = {
    enable = true;
    enableTransience = true;
  };
}
