{
  unstablePkgs,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    package = unstablePkgs.fish;
    interactiveShellInit = ''
    '';
    shellAliases = {
      "open" = "command xdg-open";
    };
    plugins = [
      rec {
        name = "puffer-fish";
        src = pkgs.fetchFromGitHub {
          owner = "nickeb96";
          repo = name;
          rev = "12d062e";
          sha256 = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
        };
      }

      {
        name = "fish-async-prompt";
        src = pkgs.fetchFromGitHub {
          owner = "acomagu";
          repo = "fish-async-prompt";
          rev = "316aa03";
          sha256 = "sha256-J7y3BjqwuEH4zDQe4cWylLn+Vn2Q5pv0XwOSPwhw/Z0=";
        };
      }
    ];
  };
  programs.zoxide = {
    enable = true;
  };
  # programs.starship = {
  #   enable = true;
  #   enableTransience = true;
  # };
}
