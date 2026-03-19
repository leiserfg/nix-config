{ pkgs, ... }:
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
}