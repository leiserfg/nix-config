{
  pkgs,
  unstablePkgs,
  lib,
  hyprPkgs,
  config,
  ...
}: let
  cursor = "Hypr-Bibata-Original-Classic";
  cursorPackage = pkgs.bibata-hyprcursor;
in {
  imports = [
    ./_wayland_common.nix
    ./_waybar.nix
  ];

  home.file.".icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";
  xdg.dataFile."icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";
  _module.args.wm = "hyprland";

  services.kanshi.systemdTarget = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
    };

    # Fix for the monitor issue, input in gamescope still broken
    # package = hyprPkgs.hyprland-debug;
    # package = hyprPkgs.hyprland;

    # systemd.variables = ["--all"];

    extraConfig = let
      env_vars = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        "HYPRCURSOR_THEME" = cursor;
        "HYPRCURSOR_SIZE" = toString (config.home.pointerCursor.size);
      };
    in ''

            ${builtins.concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (name: val: "env = ${name},${val}") env_vars
      )}


             $mod = SUPER

             # Move focus
             bind = $mod, H, movefocus, l
             bind = $mod, L, movefocus, r
             bind = $mod, K, movefocus, u
             bind = $mod, J, movefocus, d

             bind = $mod SHIFT, H, movewindow, l
             bind = $mod SHIFT, L, movewindow, r
             bind = $mod SHIFT, K, movewindow, u
             bind = $mod SHIFT, J, movewindow, d

             bind = $mod, Escape, killactive
             bind = $mod , X, exec, hyprctl kill


            # fn buttons
            binde=,XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            binde=,XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
            bind =,XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            bind =,XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            binde=,XF86MonBrightnessUp,   exec, brillo -A 10
            binde=,XF86MonBrightnessDown, exec, brillo -U 10
            # bind =,XF86AudioPlay,         exec, playerctl play-pause
            # bind =,XF86AudioPrev,         exec, playerctl previous
            # bind =,XF86AudioNext,         exec, playerctl next

            # Move/resize windows with mod + LMB/RMB and dragging
            bindm = $mod, mouse:272, movewindow
            bindm = $mod, mouse:273, resizewindow


             bind=$mod,f,fullscreen
             bind = $mod, Slash, exec, firefox
             bind = $mod, Return, exec, kitty -1

             bind = $mod, S, exec, sh -c "cat ~/.config/shikane/config.toml|grep name|sed -E 's/.*\"(.*)\"/\1/' | rofi -dmenu -i  | xargs shikanectl switch"


             bind = ,Print, exec, ${lib.getExe pkgs.grimblast} save output - | ${lib.getExe pkgs.swappy} -f -
             bind = SHIFT,Print, exec,  ${lib.getExe pkgs.grimblast} save area - | ${lib.getExe pkgs.swappy} -f -

             bind = $mod, G, exec, game-picker
             bind = $mod, 0, exec, rofi_power
             bind = $mod, P, exec, rofi_power
             bind = $mod, D, exec, rofi-launch

             bind = CTRL ALT $mod , comma, movecurrentworkspacetomonitor, l
             bind = CTRL ALT $mod , period, movecurrentworkspacetomonitor, r

             # workspaces

             ${builtins.concatStringsSep "\n" (
        lib.lists.imap1 (
          ws: code: ''
            bind = $mod, ${code}, workspace, ${toString ws}
            bind = $mod SHIFT, ${code}, movetoworkspace, ${toString ws}

            bind = $mod, ${toString ws}, workspace, ${toString ws}
            bind = $mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}
          ''
        )
        (lib.strings.stringToCharacters "QWERTYUIO")
      )}

          # debug {
          #    disable_logs = false
          # }

          general {
              layout = master
              gaps_out = 4
          }

          cursor {
              inactive_timeout = 10
          }

          misc {
              # enable_swallow = true
              # swallow_regex = ^(kitty)$
              # disable_hyprland_logo = true
              # background_color=rgb(000000)
          }

          gestures {
              workspace_swipe = true
              workspace_swipe_fingers = 4
          }

          binds {
            workspace_back_and_forth = true
          }

          xwayland {
               force_zero_scaling = true
          }
          input {
              kb_layout = us
              kb_variant = altgr-intl
              follow_mouse = 2

              touchpad {
                disable_while_typing = true
                natural_scroll = true
              }

          }

        # workspace rules

        # No gaps for single window
        workspace = w[t1], gapsin:0, gapsout:0, border:0

        #WINDOW RULES
        windowrule = workspace 1,firefox
        windowrule = workspace 4,org.telegram.desktop
        windowrule = center,pwvucontrol
        windowrule = float,pwvucontrol
        windowrule = pin,dragon


        windowrulev2 = idleinhibit fullscreen, fullscreen:1

         # debug {
         #     disable_logs = false
         # }

        layerrule = noanim,rofi
        layerrule = dimaround,rofi

      # here and not as a systemd unit so it inherits PATH
       exec-once = hypridle
       exec-once = swaybg -i ~/wall.png -m fill
       # exec-once = env WAYLAND_DEBUG=1 shikane 2> /tmp/shikane.log
    '';
  };

  # exec-once = sleep 6 && shikane
  home.packages = [pkgs.swaybg];

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        # disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202,211,245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
          shadow_passes = 2;
        }
      ];
    };
  };

  programs.hypridle = {
    enable = true;
    package = pkgs.hypridle; # it's not in stable yet
    lockCmd = "pidof hyprlock || hyprlock";

    beforeSleepCmd = "loginctl lock-session"; # lock before suspend.
    afterSleepCmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.

    listeners = [
      {
        timeout = 5 * 60; # 5min
        onTimeout = "loginctl lock-session"; # lock screen when timeout has passed
      }

      {
        timeout = builtins.floor (5.5 * 60); # 5.5min
        onTimeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        onResume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
      }
      {
        timeout = 30 * 60;
        onTimeout = "systemctl suspend"; # suspend pc
      }
    ];
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      # xdg-hypr
    ];
  };
}
