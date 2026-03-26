{ pkgs, lib, ... }:
let
  noctalia-settings = pkgs.writeTextFile {
    name = "noctalia-settings.json";
    text = builtins.toJSON {
      appLauncher.terminalCommand = "kitty";
      audio.cavaFrameRate = 30;
      audio.visualizerType = "wave";

      bar = {
        density = "compact";
        position = "top";
        showCapsule = true;
        outerCorners = false;
        widgets = {
          center = [
            {
              colorizeIcons = false;
              hideMode = "hidden";
              id = "ActiveWindow";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              useFixedWidth = false;
            }
          ];
          left = [
            {
              colorizeIcons = false;
              hideUnoccupied = false;
              id = "TaskbarGrouped";
              labelMode = "index";
              showLabelsOnlyWhenOccupied = true;
            }
            {
              hideMode = "hidden";
              hideWhenIdle = false;
              id = "MediaMini";
              maxWidth = 145;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          right = [
            {
              id = "ScreenRecorder";
            }
            {
              blacklist = [ ];
              colorizeIcons = false;
              drawerEnabled = false;
              id = "Tray";
              pinned = [ ];
            }
            {
              hideWhenZero = true;
              id = "NotificationHistory";
              showUnreadBadge = true;
            }
            {
              displayMode = "onhover";
              id = "Battery";
              warningThreshold = 30;
            }
            {
              displayMode = "onhover";
              id = "Volume";
            }
            {
              displayMode = "onhover";
              id = "Brightness";
            }
            {
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              id = "Clock";
              useCustomFont = false;
              usePrimaryColor = true;
            }
            {
              colorizeDistroLogo = false;
              customIconPath = "";
              icon = "noctalia";
              id = "ControlCenter";
              useDistroLogo = false;
            }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Monochrome";
      wallpaper.enabled = false;
      general = {
        avatarImage = "/home/leiserfg/.face";
        radiusRatio = 0.2;
      };
      wallpaper.defaultWallpaper = "/home/leiserfg/wall.png";
      location = {
        monthBeforeDay = false;
        name = "Berlin, Germany";
      };
      dock.enabled = false;
      nightLight.enabled = false;
    };
  };
in
{
  home.packages = [ pkgs.noctalia-shell ];
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = "https://docs.noctalia.dev";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
      Restart-Triggers = "${noctalia-settings}";
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.noctalia-shell}";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Optionally, create a symlink to the settings file in a known location
  home.file.".config/noctalia/settings.json".source = noctalia-settings;
  # home.file.".config/noctalia/plugins.json".source = pkgs.writeTextFile {
  #   name = "noctalia-plugins.json";
  #   text = builtins.toJSON {
  #     sources = [
  #       {
  #         enabled = true;
  #         name = "Noctalia Plugins";
  #         url = "https://github.com/noctalia-dev/noctalia-plugins";
  #       }
  #     ];
  #     states = {
  #       tailscale = {
  #         enabled = true;
  #         sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
  #       };
  #     };
  #     version = 2;
  #   };
  # };
}
