{
  pkgs,
  lib,
  ...
} @ inputs: {
  home.packages = with pkgs; [
    autorandr
    xsel
    arandr
    xorg.xrandr
    xorg.xev
    xcwd

    rofi
  ];

  xsession.enable = true;
  services = {
    xsettingsd = {
      enable = false;
      settings = {
        "Xft/DPI" = 98304;
        "Xft/Antialias" = true;
        "Xft/HintStyle" = "hintfull";
        "Xft/Hinting" = true;
        "Xft/RGBA" = "none";
      };
    };

    picom = {
      enable = true;
      vSync = true;
      backend = "xr_glx_hybrid";
      settings = {
        # xrender-sync-fence = true;
      };
    };
    caffeine.enable = true;
    unclutter.enable = true;

    # home.services = {
    #   flameshot.enable = false;
    # };

    polybar = {
      enable = true;

      package = pkgs.polybar.override {
        i3Support = true;
        # pulseSupport = true;
      };

      script = "polybar top&";
      config = {
        "bar/top" = {
          width = "100%";
          height = "2%";
          radius = 0;

          modules-left = "i3";
          modules-center = "xwindow";
          modules-right = "date";

          tray-position = "right";
          tray-padding = 2;
          tray-maxsize = 100;

          font-0 = "Iosevka Term SS07:style=SemiBold";
          font-1 = "Symbols Nerd Font:style=Regular";
          font-2 = "EmojiOne:style=Regular:scale=10";
        };

        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d.%m.%y";
          time = "%H:%M";
          label = "%time%  %date%";
        };

        "module/i3" = {
          type = "internal/i3";
          enable-click = true;
          pin-workspaces = true;
          enable-scroll = false;

          # label-focused-background = ${colors.primary}
          # label-focused-foreground = ${colors.background}
          #
          # label-urgent-background = ${colors.alert}
          # ; hide empty workspaces
          # label-empty = "";
        };

        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:50:…%";
        };
        # "module/pulseaudio" = {
        #   type = "internal/pulseaudio";
        #   format-volume = "%{A3:pavucontrol:} <ramp-volume> <label-volume> %{A}";
        #   label-muted = "🔇";
        #   label-muted-foreground = "#666";
        #   ramp-volume-0 = "🔈";
        #   ramp-volume-1 = "🔉";
        #   ramp-volume-2 = "🔊";
        # };
      };
    };
  };

  xsession.windowManager.i3 =
    lib.attrsets.recursiveUpdate {
      config = {
        assigns = {
          "1" = [
            {class = "^firefox$";}
          ];
          "4" = [
            {class = "^telegram-desktop$";}
          ];
        };
      };
      extraConfig = ''
        for_window [class="dragon"] sticky enable
        for_window [title="Picture-in-Picture"] sticky enable
      '';
    }
    # Common stuff
    (import ./i3-sway.nix inputs);
}
