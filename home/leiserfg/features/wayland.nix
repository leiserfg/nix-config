{
  pkgs,
  unstablePkgs,
  lib,
  ...
} @ inputs: {
  home.packages = with pkgs; [
    rofi-wayland
    wev
    wl-clipboard
    wdisplays
  ];

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
        # modules-left = ["hyprland/workspaces"];
        # modules-center = ["hyprland/window"];

        modules-left = ["sway/workspaces"];
        modules-center = ["sway/window"];

        modules-right = [
          "battery"
          "tray"
          "wireplumber"
          "custom/pp"
          "clock"
          #  currently using applets
          # "network"
          /*
          "bluetooth"
          */
        ];
        layer = "top";

        "sway/workspaces" = {
          format = "{name} {icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };

        "custom/pp" = {
          exec = "pp-state";
          on-click = "rofi-pp && pkill -SIGRTMIN+9 waybar";
          signal = 9;
          interval = "once";
        };

        "hyprland/window" = {
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

  wayland.windowManager.sway = lib.attrsets.mergeAttrsList [
    {
      package = unstablePkgs.sway.override {
        extraSessionCommands = ''
          # home-manager on non nixos stuff
          source ~/.nix-profile/etc/profile.d/hm-session-vars.sh

          export XWAYLAND_NO_GLAMOR=1
          export MOZ_ENABLE_WAYLAND=1
          export XDG_SESSION_TYPE=wayland

          if command -v nvidia-smi >/dev/null 2>&1; then
            export WLR_RENDERER=vulkan
            export WLR_NO_HARDWARE_CURSORS=1
            export LIBVA_DRIVER_NAME=nvidia
            export GBM_BACKEND=nvidia-drm
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export WLR_NO_HARDWARE_CURSORS=1
          fi
        '';

        # Don't complain if it's nvidia (but it should not be)
        extraOptions = ["--unsupported-gpu"];
        withBaseWrapper = true;
        withGtkWrapper = true;
      };

      config = {
        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_variant = "altgr-intl";
          };
        };

        seat = {
          "*" = {
            hide_cursor = "when-typing enable";
          };
        };
        output = {
          "*" = {bg = "~/wall.png fill";};
        };

        assigns = {
          "1" = [
            {app_id = "^firefox$";}
          ];
          "4" = [
            {app_id = "^org.telegram.desktop$";}
          ];
        };

        extraConfig = ''
          for_window [app_id="dragon"] sticky enable
          for_window [class="dragon"] sticky enable
          for_window [title="Picture-in-Picture"] sticky enable
        '';
      };
    }

    # Common stuff
    (import ./i3-sway.nix inputs)
  ];
}
