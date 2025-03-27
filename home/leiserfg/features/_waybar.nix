{
  pkgs,
  wm,
  ...
} @ inputs: {
  home.packages = [pkgs.swaynotificationcenter];
  programs.waybar = {
    enable = true;
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
          font-family: 'monospace';
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
          "wireplumber"
          "battery"
          "tray"
          "power-profiles-daemon"
          "clock"
          #  currently using applets
          # "network"
          /*
          "bluetooth"
          */
          "custom/notification"
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
            "default" = "";
            "performance" = "";
            "balanced" = "";
            "power-saver" = "";
          };
        };

        wireplumber = {
          "format" = "󰕿 {volume}%";
          "format-muted" = " ";
          on-click = "pavucontrol";
          on-click-right = "qpwgraph";
          on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        battery = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} {capacity}%";
          "format-icons" = ["" "" "" "" ""];
        };

        clock = {
          "format" = "{:%H:%M}";
          "format-alt" = "{:%A, %B %d, %Y (%R)}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "month";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          "actions" = {
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
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
        "custom/notification" = {
          "tooltip" = false;
          "format" = "{icon}";
          "format-icons" = {
            "notification" = "<span foreground='red'><sup></sup></span>";
            "none" = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          "exec" = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          "escape" = true;
        };
      };
    };
  };
}
