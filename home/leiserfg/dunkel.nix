{
  pkgs,
  unstablePkgs,
  ...
}:
{
  imports = [
    ./common.nix
    # ./features/mesa.nix
    ./features/hyprland.nix
    # ./features/daw.nix
  ];
  home.packages = with pkgs; [
    # centrifugo
    pgcli
    pre-commit
    poetry
    insomnia
    awscli2
    csvkit
    libreoffice-qt6
    terraform
    # traceroute
    poedit
    # (unstablePkgs.teams-for-linux)
    # slack
  ];

  services.shikane = {
    enable = true;
    settings = {
      profile = [
        {
          name = "ultra-wide-lg";
          output = [
            {
              match = "eDP-1";
              enable = false;
            }
            {
              search = [ "m=LG HDR WQHD" ];
              enable = true;
              scale = 1.6666;
              mode = "3840x1600@59.99300";
            }
          ];
        }

        {
          name = "ultra-wide-dell";
          output = [
            {
              match = "eDP-1";
              enable = false;
            }
            {
              search = [ "m=DELL U3421WE" ];
              enable = true;
              scale = 1.6666;
              mode = "3440x1440@59.97300";
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

}
