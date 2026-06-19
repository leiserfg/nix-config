{
  unstablePkgs,
  pkgs,
  lib,
  config,
  ...
}:
{

  home.file."${config.xdg.configHome}/nushell/nix-your-shell.nu".source =
    pkgs.nix-your-shell.generate-config "nu";

  home.packages = [
    (pkgs.runCommand "nushell-fzf-integration" { } ''
      mkdir -p $out/share/nushell/vendor/autoload
      ${lib.getExe pkgs.fzf} --nushell > $out/share/nushell/vendor/autoload/fzf.nu
    '')

  ];
  programs = {
    nushell = {
      enable = true;
      extraConfig = (builtins.readFile ./config.nu) + ''
        source ${./notebook_theme.nu}
        source ${./brace-expand.nu}
        source ${./psub.nu}
      '';
      shellAliases = {
        fg = "job unfreeze";
        vi = "nvim";
        vim = "nvim";
        awsl = "awslogs groups | fzf | xargs awslogs get -G -S -w";
        ruff-nvim = "ruff check --output-format=concise | nvim +copen -q -";
      };

      plugins = [
        pkgs.nushellPlugins.formats
        pkgs.nushellPlugins.query
      ];

    };
    carapace.enable = true;
    carapace.enableNushellIntegration = false; # Enabled  by hand in the config
    # carapace.enableBashIntegration = false;
  };
}
