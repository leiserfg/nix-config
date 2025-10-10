{
  unstablePkgs,
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.fish = {
    enable = false;
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
    enable = config.programs.fish.enable;
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
        # "$git_branch"
        # "$git_commit"
        # "$git_state"
        # "$git_metrics"
        # "$git_status"
        "$custom"
      ];
      custom.jj = {
        ignore_timeout = true;

        description = "The current jj status";
        detect_folders = [ ".jj" ];
        symbol = "🥋 ";
        command = ''
          jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
            separate(" ",
              change_id.shortest(4),
              bookmarks,
              "|",
              concat(
                if(conflict, "💥"),
                if(divergent, "🚧"),
                if(hidden, "👻"),
                if(immutable, "🔒"),
              ),
              raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
              raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                truncate_end(29, description.first_line(), "…"),
                "(no description set)",
              ) ++ raw_escape_sequence("\x1b[0m"),
            )
          '
        '';
      };
      custom.git_branch = {
        when = true;
        command = "jj root >/dev/null 2>&1 || starship module git_branch";
        description = "Only show git_branch if we're not in a jj repo";
      };

    };
  };
}
