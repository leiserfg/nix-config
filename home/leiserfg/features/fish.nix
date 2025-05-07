{
  unstablePkgs,
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    package = pkgs.fish;
    shellAliases = {
      "open" = "command xdg-open";
      "vi" = "command nvim";
    };
    functions = {
      aws_profile = ''
        commandline (aws configure list-profiles | fzf --reverse | xargs -I {} echo export AWS_PROFILE={})
      '';
      fish_greeting = "";
    };
    plugins = [
      rec {
        name = "puffer-fish";
        src = pkgs.fetchFromGitHub {
          owner = "nickeb96";
          repo = name;
          rev = "12d062e";
          sha256 = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
          fetchSubmodules = true;
        };
      }
    ];
  };
  programs.zoxide = {
    enable = true;
  };
  programs.lsd = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[❱](green)";
        error_symbol = "[✗](bold red)";
      };
      #
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$character"
      ];
      git_branch.format = "[$symbol$branch(:$remote_branch)]($style)";
      python.format = "[\${symbol}\${version} ]($style)";
      python.symbol = " ";
      hostname.format = "@$hostname ";
      directory = {
        truncation_symbol = "…/";
      };

      right_format = lib.concatStrings [
        "$python"
        "$hostname"
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
