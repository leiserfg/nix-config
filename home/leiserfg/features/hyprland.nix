{
  pkgs,
  unstablePkgs,
  lib,
  hyprPkgs,
  config,
  ...
}:
let
  cursor = "Bibata-Original-Classic";
  cursorPackage = pkgs.bibata-hyprcursor;
in
{
  imports = [
    ./_wayland_common.nix
    ./_waybar.nix
  ];

  _module.args.wm = "hyprland";

  services.kanshi.systemdTarget = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
    };

    plugins = [ pkgs.hyprlandPlugins.hyprspace ];
    settings = {
      "$mod" = "SUPER";
      bind =
        [

          # Move focus
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"

          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          "$mod, Escape, killactive"
          "$mod , X, exec, hyprctl kill"

          "$mod,f,fullscreen"
          "$mod, Slash, exec, firefox"
          "$mod, Return, exec, kitty -1"

          ''$mod, S, exec, sh -c "cat ~/.config/shikane/config.toml|grep name|sed -E 's/.*\"(.*)\"/\1/' | rofi -dmenu -i  | xargs shikanectl switch"''

          ",Print, exec, ${lib.getExe pkgs.grimblast} save output - | ${lib.getExe pkgs.swappy} -f -"
          "SHIFT,Print, exec,  ${lib.getExe pkgs.grimblast} save area - | ${lib.getExe pkgs.swappy} -f -"

          "$mod, G, exec, game-picker"
          "$mod, 0, exec, rofi_power"
          "$mod, P, exec, rofi_power"
          "$mod, D, exec, rofi-launch"

          "CTRL ALT $mod , comma, movecurrentworkspacetomonitor, l"
          "CTRL ALT $mod , period, movecurrentworkspacetomonitor, r"

          ",XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ]
        ++ (builtins.concatLists (
          lib.lists.imap1 (ws: code: [
            "$mod, ${code}, workspace, ${toString ws}"
            "$mod SHIFT, ${code}, movetoworkspace, ${toString ws}"

            "$mod, ${toString ws}, workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
          ]) (lib.strings.stringToCharacters "QWERTYUIO")
        ))

      ;
      binde = [
        ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86MonBrightnessUp,   exec, brillo -A 10"
        ",XF86MonBrightnessDown, exec, brillo -U 10"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # debug = {
      #    disable_logs = false;
      # }

      general = {
        layout = "master";
        gaps_out = 3;
        gaps_in = 4;
        "col.active_border" = "rgb(bb3344) rgb(33bb44) 45deg";
        border_size = 2;
      };

      cursor = {
        inactive_timeout = 10;
      };

      misc = {
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
        swallow_exception_regex = "^(wev).*";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };

      binds = {
        workspace_back_and_forth = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        follow_mouse = 2;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
        };
      };

      # No gaps for single window
      workspace = "w[t1], gapsin:0, gapsout:0, border:0";

      windowrule = [
        "workspace 1,class:firefox"
        "workspace 4,class:org.telegram.desktop"
        "center,class:pavucontrol"
        "float,class:pavucontrol"
        "pin,class:dragon-drop"
        "idleinhibit fullscreen, fullscreen:1"
      ];

      layerrule = [
        "noanim,rofi"
        "dimaround,rofi"
      ];

      exec-once = [
        # here and not as a systemd unit so it inherits PATH
        "hypridle"

        "swaybg -i ~/wall.png -m fill"
      ];
      env = lib.attrsets.mapAttrsToList (name: val: "${name},${toString val}") {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        HYPRCURSOR_THEME = cursor;
        HYPRCURSOR_SIZE = config.home.pointerCursor.size;
        GRIMBLAST_HIDE_CURSOR = 0;
      };
    };
  };

  home.packages = [
    pkgs.swaybg
    pkgs.bibata-hyprcursor
  ];

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
    ];
  };
}
