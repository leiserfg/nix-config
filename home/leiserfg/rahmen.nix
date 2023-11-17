{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/x11.nix  ./features/laptop.nix];

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    unstablePkgs.blender-hip
    unstablePkgs.gamescope
    unstablePkgs.godot_4
    nix-ld
  ];

  services = {
    grobi = {
      enable = true;
      rules = [
        {
          name = "Home";
          outputs_connected = ["DP-2"];
          configure_single = "DP-2";
          primary = true;
          atomic = true;
          execute_after = [
            ''
              echo "Xft.dpi: 96" | ${pkgs.xorg.xrdb}/bin/xrdb -merge

            ''
          ];
        }
        {
          name = "Mobile";
          outputs_disconnected = ["DP-2"];
          configure_single = "eDP-1";
          primary = true;
          atomic = true;
          execute_after = [
            ''
             echo "Xft.dpi: 144" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
            ''
          ];
        }
      ];
    };

    kanshi = {
      enable = false;

      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.5;
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
