{
  unstablePkgs,
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;
    package = pkgs.fish;
    interactiveShellInit = ''
      set  fish_color_autosuggestion      black
      set  fish_color_cancel              -r
      set  fish_color_command             brgreen
      set  fish_color_comment             brmagenta
      set  fish_color_cwd                 green
      set  fish_color_cwd_root            red
      set  fish_color_end                 brmagenta
      set  fish_color_error               brred
      set  fish_color_escape              brcyan
      set  fish_color_history_current     --bold
      set  fish_color_host                normal
      set  fish_color_match               --background=brblue
      set  fish_color_normal              normal
      set  fish_color_operator            cyan
      set  fish_color_param               brblue
      set  fish_color_quote               yellow
      set  fish_color_redirection         bryellow
      set  fish_color_search_match        'bryellow' '--background=brblack'
      set  fish_color_selection           'white' '--bold' '--background=brblack'
      set  fish_color_status              red
      set  fish_color_user                brgreen
      set  fish_color_valid_path          --underline
      set  fish_pager_color_completion    normal
      set  fish_pager_color_description   yellow
      set  fish_pager_color_prefix        'white' '--bold' '--underline'
      set  fish_pager_color_progress      'brwhite' '--background=cyan'
    '';
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
