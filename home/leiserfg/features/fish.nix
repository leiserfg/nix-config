{
  unstablePkgs,
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;
    package = unstablePkgs.fish;
    # interactiveShellInit = '''';
    shellAliases = {
      "open" = "command xdg-open";
      "vi" = "command nvim";
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
    ];
  };
  programs.zoxide = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$character"
      ];
      git_branch.format = "[$symbol$branch(:$remote_branch)]($style)";
      python.format = "\${symbol}\${version} ";
      python.symbol = " ";

      directory = {
        truncation_symbol = "…/";
      };

      right_format = lib.concatStrings [
        "$python"
        "$aws"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
      ];
    };
  };
}
