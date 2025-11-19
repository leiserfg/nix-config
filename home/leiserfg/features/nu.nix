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
    carapace.enableNushellIntegration = false; # Enabled  by hand in the config
  };
}
