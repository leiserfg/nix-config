{
  pkgs,
  unstablePkgs,
  config,
  ...
}: {
  imports = [
    ./common.nix
    # ./features/x11.nix
    ./features/hyprland.nix
    ./features/laptop.nix
    ./features/games.nix
    # ./features/daw.nix
  ];

  home.packages = with pkgs; [
    rpi-imager
    pgcli
    pre-commit
    poetry
    # unstablePkgs.blender-hip
    gamescope

    # unstablePkgs.godot_4
    nix-ld
    swaylock
    # audacity
    ddcutil
    moonlight-qt
    # gnome-network-displays
    # anki
  ];

  services = {
    grobi = {
      enable = config.xsession.enable;
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
      # enable = !config.xsession.enable;
      enable = true;
      systemdTarget = "hyprland-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              scale = 1.175000;
            }
          ];
        }
        {
          profile.name = "docked-left";
          profile.outputs = [
            {
              criteria = "DP-3";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
        {
          profile.name = "docked-right";
          profile.outputs = [
            {
              criteria = "DP-2";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
      ];
    };
  };
}
