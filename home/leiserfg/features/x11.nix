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
  ];

  xsession.enable = true;

  services = {
    flameshot.enable = true;
    picom = {
      enable = true;
      vSync = true;
      backend = "xrender";
      # backend = "xr_glx_hybrid";
      settings = {
        # xrender-sync-fence = true;
      };
    };
    caffeine.enable = true;
    unclutter.enable = true;

    polybar = {
      enable = true;

      package = pkgs.polybar.override {
        i3Support = true;
        # pulseSupport = true;
      };

      script = "polybar top&";
      config = let
        colors = {
          background = "#2f343f";
          background-alt = "#2f343f";
          foreground = "#dfdfdf";
          foreground-alt = "#555";
          primary = "#afcfee";
          secondary = "#e60053";
          alert = "#bd2c40";
        };
      in {
        "bar/top" = {
          dpi = "\${xrdb:Xft.dpi:-1}";

          width = "100%";
          height = "1.8%";
          radius = 0;

          modules-left = "i3";
          modules-center = "xwindow";
          modules-right = "date";

          tray-position = "right";
          tray-padding = 2;
          tray-maxsize = 100;

          background = colors.background;
          foreground = colors.foreground;

          font-0 = "Iosevka Term SS07:style=SemiBold;2";
          font-1 = "Symbols Nerd Font:style=Regular";
          font-2 = "EmojiOne:style=Regular:scale=10";

          line-size = 3;
          line-color = "#f00";

          border-size = 0;
          border-color = "#00000000";

          padding-left = 0;
          padding-right = 0;

          module-margin-left = 0;
          module-margin-right = 1;
        };

        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d-%m-%y %a";
          time = "%I:%M";
          label = "%time% %date%";
        };

        "module/i3" = {
          type = "internal/i3";
          enable-click = true;
          pin-workspaces = true;
          enable-scroll = false;

          label-focused-background = colors.primary;
          label-focused-foreground = colors.background;
          label-urgent-background = colors.alert;
          # ; hide empty workspaces
          # label-empty = "";

          # ws-icon-0 = "1; ";
          # ws-icon-1 = "2; ";
          # ws-icon-2 = "3; ";
          # ws-icon-3 = "4; ";
          # ws-icon-default = "";
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
        settings = {
          screenchange-reload = true;
        };
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
        exec_once ${pkgs.feh}/bin/feh --bg-center ~/wall.png
      '';
    }
    # Common stuff
    (import ./i3-sway.nix inputs);
}
