{
  unstablePkgs,
  pkgs,
  lib,
  ...
}:
rec {
  programs = {
    nushell = {
      enable = true;
      extraConfig = builtins.readFile ./config.nu;
      shellAliases = {
        fg = "job unfreeze";
        vi = "nvim";
        vim = "nvim";
      };
      plugins = [
        pkgs.nushellPlugins.formats
        pkgs.nushellPlugins.query
      ];
    };
    carapace.enable = true;
  };
  # Workaround to avoid the gc from removing the plugins until it's fixed in home-manager
  # home.extraDependencies = programs.nushell.plugins;
}
