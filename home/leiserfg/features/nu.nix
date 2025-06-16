{
  unstablePkgs,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    nushell = {
      enable = true;
      extraConfig = builtins.readFile ./config.nu;
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };
      plugins = [ pkgs.nushellPlugins.formats ];
    };
    carapace.enable = true;
  };
}
