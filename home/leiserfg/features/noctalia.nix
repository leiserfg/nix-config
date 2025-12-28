{ pkgs, inputs, ... }:
{
  # import the home manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # configure options
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      appLauncher.terminalCommand = "kitty";
      audio.cavaFrameRate = 30;
      audio."visualizerType" = "wave";

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
}
