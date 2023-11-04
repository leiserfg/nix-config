{
  pkgs,
  unstablePkgs,
  inputs,
  myPkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./features/games.nix
    /*
    ./features/daw.nix
    */
  ];
  home.packages = with pkgs; [
    unstablePkgs.steam-run
    # unstablePkgs.steam
    /*
    myPkgs.ansel
    */
    ventoy-bin
    blender_3_6
    /*
    unstablePkgs.godot_4
    */
    rink
    sunvox
    unstablePkgs.uiua
    krita
    /*
    davinci-resolve
    */
    /*
    audacity
    */
    /*
    abiword
    */
    tree-sitter
    nmap
    # brave

    hyprpicker
    rofi-wayland

    /*
    xdg-desktop-portal
    */
    /*
    xdg-desktop-portal-hyprland
    */
    wev
    wl-clipboard
    swaybg
    # gamescope

    (writeShellScriptBin "rofi-launch" ''
      exec -a $0 rofi -combi-modi window,drun,ssh -show combi -modi combi -show-icons
    '')

    (
      writeShellScriptBin "rofi-pp" ''
        printf " Performance\n Balanced\n Power Saver" \
        | rofi -dmenu -i \
        | tr -cd '[:print:]' \
        | xargs|tr " " "-" \
        | tr '[:upper:]' '[:lower:]' \
        | xargs powerprofilesctl set
      ''
    )
    (
      writeShellScriptBin "pp-state" ''
        state=$(powerprofilesctl get | sed -e "s/.*string//" -e "s/.*save.*/ /"  -e "s/.*perf.*/ /"  -e "s/.*balanced.*/ /")
        printf %s\n\n $state
      ''
    )
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
        network = {
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname} ";
          format-disconnected = "";
          tooltip-format = "{ifname}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };
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
          signal=9;
          interval="once";
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

  wayland.windowManager.sway = {
    enable = true;

    package = unstablePkgs.sway.override {
      extraSessionCommands = ''
        export WLR_RENDERER=vulkan
        export WLR_NO_HARDWARE_CURSORS=1
        export XWAYLAND_NO_GLAMOR=1
      '';

      extraOptions = ["--unsupported-gpu"];
      withBaseWrapper = true;
      withGtkWrapper = true;
    };

    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      assigns = {"2: web" = [{class = "^firefox$";}];};
      focus = {
        followMouse = "always";
        newWindow = "smart";
      };
      defaultWorkspace = "workspace number 1";
      workspaceAutoBackAndForth = true;
      window = {
        hideEdgeBorders = "smart";
        border = 2;
      };
      gaps = {
        top = 1;
        bottom = 1;
        horizontal = 5;
        vertical = 5;
        inner = 5;
        outer = 5;
        left = 5;
        right = 5;
        smartBorders = "on";
        smartGaps = true;
      };
      keybindings = {
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";

        "${modifier}+${left}" = "focus left";
        "${modifier}+${down}" = "focus down";
        "${modifier}+${up}" = "focus up";
        "${modifier}+${right}" = "focus right";
        "${modifier}+Return" = "exec kitty";

        "${modifier}+q" = "kill";
        "Mod1+Shift+q" = "exit";
        "Mod4+b" = "splith";
        "Mod4+v" = "splitv";
        "Mod4+s" = "reload";
        # "Mod4+s" = "layout stacking";
        "Mod4+w" = "layout tabbed";
        "Mod4+e" = "layout toggle split";
        "Mod4+f" = "fullscreen";
        "Mod4+Shift+space" = "floating toggle";
        "Mod4+space" = "focus mode_toggle";
        "Mod4+slash" = "exec firefox";
        "Mod4+d" = "exec --no-startup-id rofi-launch";
        "Mod4+0" = "exec rofi_power";

        "Print" = "exec ${pkgs.wayshot}/bin/wayshot -f /tmp/foo.png; exec sleep 1; exec ${pkgs.wl-clipboard}/bin/wl-copy -t image/png < /tmp/foo.png"; # TODO: would like to change the program for screenshots
        "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";
        "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer --allow-boost -i 5";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer --allow-boost -d 5";
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute";
        "Mod4+Shift+i" = "move scratchpad";
        "Mod4+i" = "scratchpad show";
      };
      up = "k";
      down = "j";
      right = "l";
      left = "h";
      floating = {
        titlebar = false;
        criteria = [{class = "feh";} {title = "Mpv";} {class = "meh";}];
        modifier = "Mod4";
      };
      fonts = {};
      modes = {
        resize = {
          h = "resize shrink width 10 px";
          j = "resize grow height 10 px";
          k = "resize shrink height 10 px";
          l = "resize grow width 10 px";
          Escape = "mode default";
          Return = "mode default";
        };
      };
      startup = [
        {
          command = "swayidle -w timeout 60 'swaylock -f -c 000000' timeout 75 swaymsg output * dpms off resume swaymsg output * dpms on before-sleep swaylock -f -c 000000";
          always = true;
        }
        {
          command = "${pkgs.autotiling}/bin/autotiling";
          always = true;
        }
      ];
      menu = "${pkgs.wofi}/bin/wofi --insensitive --show drun,run";
      bars = [];
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
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    systemdIntegration = true;
    extraConfig = ''

          env = LIBVA_DRIVER_NAME,nvidia
          env = GBM_BACKEND,nvidia-drm
          env = __GLX_VENDOR_LIBRARY_NAME,nvidia
          env = WLR_NO_HARDWARE_CURSORS,1


          env = MOZ_ENABLE_WAYLAND,1
          env = XDG_CURRENT_DESKTOP=Hyprland
          env = XDG_SESSION_DESKTOP=Hyprland
          env = XDG_SESSION_TYPE,wayland

          bind = SUPER,Return,exec,kitty
          bind = SUPER,slash,exec,firefox
          bind = , Print, exec, grimblast copy area
          bind = SUPER,F,fullscreen
          bind = SUPER,d,exec,rofi -combi-modi window,drun,ssh -show combi -modi combi -show-icons

          bind = SUPER,j,movefocus,d
          bind = SUPER,k,movefocus,u
          bind = SUPER,h,movefocus,l
          bind = SUPER,l,movefocus,r


          bind = SUPER SHIFT,j,swapwindow,d
          bind = SUPER SHIFT,k,swapwindow,u
          bind = SUPER SHIFT,h,swapwindow,l
          bind = SUPER SHIFT,l,swapwindow,r



          bind = SUPER,a,killactive

          bindm=SUPER,mouse:272,movewindow
          bindm=SUPER,mouse:273,resizewindow

          bind = SUPER,g,exec,~/bin/game_pick
          bind = SUPER,0,exec,rofi_power
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          ${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = SUPER, ${ws}, workspace, ${toString (x + 1)}
            bind = SUPER SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
        9)}
        input {
          # 2 means mouse is detached from keyboard and clicking a windows attaches it, kinda like x11
          follow_mouse = 2

          kb_layout = us
          kb_variant = altgr-intl

        }
        general {
         layout = master
          gaps_in = 4
          gaps_out = 8
          cursor_inactive_timeout = 3
        }
        master {
          no_gaps_when_only = true
        }

        binds {
          workspace_back_and_forth = true
        }

      # ScreenSharing
      exec-once=${inputs.hyprland.packages.x86_64-linux.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland --verbose
      exec-once=${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal --verbose

      #Wallpaper
      exec-once=swaybg -i ~/wall.png
    '';
  };
}
