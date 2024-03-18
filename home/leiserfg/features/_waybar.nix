{
  unstablePkgs,
  wm,
  ...
} @ inputs: {
  programs.waybar = {
    enable = true;
    package = unstablePkgs.waybar;
    systemd.enable = true;
    style = ''
      * {
          font-size: 13px;
          border: none;
          border-radius: 0;
      }
      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      #workspaces button {
        padding: 0 2px;
        background: transparent;
        color: white;
        border-bottom: 3px solid transparent;
      }


      #workspaces button.active,
      #workspaces button.focused {
          border-bottom: 2px solid lightblue;
      }

      #workspaces button.urgent {
          border-bottom: 2px solid red;
      }


      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
          padding: 0 0 0 .5rem;
          color: #ffffff;
      }
      #tray > widget {
        padding-left: 2px;
      }
      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }
    '';

    settings = {
      mainbar = {
        margin-left = 2;
        margin-right = 2;
        modules-left = ["${wm}/workspaces"];
        modules-center = ["${wm}/window"];

        modules-right = [
          "battery"
          "tray"
          "power-profiles-daemon"
          "clock"
          #  currently using applets
          # "network"
          /*
          "bluetooth"
          */
        ];
        layer = "top";

        "${wm}/workspaces" = {
          format = "{name} {icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };
        power-profiles-daemon = {
          "format" = "{icon}";
          "tooltip-format" = "Power profile= {profile}\nDriver= {driver}";
          "tooltip" = true;
          "format-icons" = {
            "default" = "";
            "performance" = "";
            "balanced" = "";
            "power-saver" = "";
          };
        };
        battery = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{capacity}% {icon}";
          "format-icons" = ["" "" "" "" ""];
        };

        "${wm}/window" = {
          "rewrite" = {
            "(.*) — Mozilla Firefox" = "🌎 $1";
            "(.*) - fish" = "  [$1]";
          };
          tray = {
            spacing = 2;
          };
        };
      };
    };
  };
}
