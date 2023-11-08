{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/mesa.nix ./features/wayland.nix];
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    terraform
    terraform-ls
    insomnia
    awscli2
    csvkit
    libreoffice
    pandoc

  ];

services = {
    kanshi = {
      enable = true;

      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale=1.0;
            }
          ];
        };

        docked = {
          outputs = [
            {
              criteria = "DP-1";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      };
    };
  };

}
