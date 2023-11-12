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
    blender-hip
    unstablePkgs.gamescope
    unstablePkgs.godot_4
    nix-ld
  ];

  services = {
    kanshi = {
      enable = true;

      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale=1.5;
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
