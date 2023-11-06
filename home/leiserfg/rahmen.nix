{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/wayland.nix];

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
  ];

  services = {
    kanshi = {
      enable = true;

      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        };

        docked = {
          outputs = [
            {
              criteria = "DP-2";
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
