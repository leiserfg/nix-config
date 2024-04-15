{unstablePkgs, ...}: {
  programs.fish = {
    enable = true;
    package = unstablePkgs.fish;
    interactiveShellInit = ''
    '';
    shellAliases = {
        "open" = "command xdg-open";
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
