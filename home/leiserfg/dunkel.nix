{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [
    ./common.nix
    # ./features/mesa.nix
    ./features/hyprland.nix
    # ./features/daw.nix
  ];
  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    insomnia
    awscli2
    csvkit
    libreoffice-qt6
    terraform
    traceroute
    (unstablePkgs.teams-for-linux)
    # slack
  ];

  services.shikane = {
    enable = true;
    settings = {
      profile = [
        {
          name = "ultra-wide";
          output = [
            {
              match = "eDP-1";
              enable = false;
            }
            {
              search = ["m=DELL U3421WE"];
              enable = true;
              scale = 1.6666;
              mode = "3440x1440@59.97Hz";
            }
          ];
        }

        {
          name = "left-docked";
          output = [
            {
              match = "eDP-1";
              enable = false;
            }
            {
              search = "/.*";
              enable = true;
              scale = 1.5;
              mode = "3840x2160@60.00Hz";
            }
          ];
        }
        {
          name = "lonly";
          output = [
            {
              match = "eDP-1";
              enable = true;
              scale = 1.2;
              mode = "1920x1200@60.00Hz";
            }
          ];
        }
      ];
    };
  };

  services = {
    kanshi = {
      enable = false;
      systemdTarget = "hyprland-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              scale = 1.2;
              status = "enable";
              mode = "1920x1200@60.00300";
            }
          ];
        }

        {
          profile.name = "office";
          profile.outputs = [
            {
              criteria = "Dell Inc. DELL S2721QS GT2CM43";
              mode = "2560x1440@59.95100";
              scale = 1.333333333333;
            }

            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }

        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "DP-1";
              mode = "3840x2160";
              scale = 1.66666666;
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
