{
  pkgs,
  myPkgs,
  unstablePkgs,
  lib,
  config,
  options,
  inputs,
  ...
}:

{
  imports = [
    ./_wayland_common.nix
  ];

  home.pointerCursor.hyprcursor = {
    enable = true;
  };

  wayland.windowManager.hyprland =
    let
      lua = lib.generators.mkLuaInline;
      luaf = body: lib.generators.mkLuaInline ("function() " + body + " end");
      # Shorthand lua functions
      exec = cmd: lua "hl.dsp.exec_cmd('${cmd}')";
      focus = dir: lua "hl.dsp.focus({ direction = '${dir}' })";
      move = dir: lua "hl.dsp.window.move({ direction = '${dir}' })";
      close = lua "hl.dsp.window.close()";
      kill = lua "hl.dsp.window.kill()";
      fullscreen = lua "hl.dsp.window.fullscreen()";
      workspace_switch = ws: lua "hl.dsp.focus({ workspace = ${toString ws} })";
      workspace_move = ws: lua "hl.dsp.window.move({ workspace = ${toString ws} })";

      # Convert bind list to proper format
      mkBinds =
        bindList:
        map (
          item:
          if builtins.length item == 2 then
            {
              _args = [
                (builtins.elemAt item 0)
                (builtins.elemAt item 1)
              ];
            }
          else if builtins.length item == 3 then
            {
              _args = [
                (builtins.elemAt item 0)
                (builtins.elemAt item 1)
                (builtins.elemAt item 2)
              ];
            }
          else
            throw "Invalid bind format: expected 2 or 3 elements"
        ) bindList;

      # Generate workspace bindings
      workspaceBindings = builtins.concatLists (
        lib.lists.imap1 (ws: code: [
          [
            "SUPER+${code}"
            (workspace_switch ws)
          ]
          [
            "SUPER+SHIFT+${code}"
            (workspace_move ws)
          ]
          [
            "SUPER+${toString ws}"
            (workspace_switch ws)
          ]
          [
            "SUPER+SHIFT+${toString ws}"
            (workspace_move ws)
          ]
        ]) (lib.strings.stringToCharacters "QWERTYUIO")
      );
    in
    {
      enable = true;
      configType = "lua";
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };

      plugins = [
        # pkgs.hyprlandPlugins.hypr-dynamic-cursors
      ];

      settings = {
        config = {
          render = {
            direct_scanout = 2; # Enable in games
            cm_sdr_eotf = "srgb";
          };
          misc = {
            disable_hyprland_logo = true;
          };
          general = {
            layout = "master";
            gaps_out = 3;
            gaps_in = 4;
            "col.active_border" = {
              colors = [
                "rgba(bb3344ff)"
                "rgba(33bb44ff)"
              ];
              angle = 45;
            };
            border_size = 2;
          };
          cursor = {
            inactive_timeout = 10;
            no_hardware_cursors = 2;
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
        };

        gesture = {
          fingers = 4;
          direction = "horizontal";
          action = "workspace";
        };

        env =
          lib.attrsets.mapAttrsToList
            (name: val: {
              _args = [
                name
                val
              ];
            })
            {
              XDG_CURRENT_DESKTOP = "Hyprland";
              XDG_SESSION_TYPE = "wayland";
              XDG_SESSION_DESKTOP = "Hyprland";
              QT_QPA_PLATFORM = "wayland";
            };

        workspace_rule = [
          {
            workspace = "w[t1]";
            gaps_in = 0;
            gaps_out = 0;
            no_border = true;
          }
        ];

        window_rule = [
          {
            match.class = "firefox";
            workspace = 1;
          }
          {
            match.class = "org.telegram.desktop";
            workspace = 4;
          }
          {
            match.class = "pavucontrol";
            center = true;
            # floating = true;
          }
          {
            match.class = "pwvucontrol";
            center = true;
            # floating = true;
          }
          {
            match.initial_class = "dragon-drop";
            pin = true;
          }
          {
            match.class = ".*";
            idle_inhibit = "fullscreen";
          }
          {
            match.class = "org.telegram.desktop";
            no_screen_share = true;
          }
          {
            match.class = "vicinae";
            border_size = 0;
          }
        ];

        layer_rule = [
          {
            match.namespace = "vicinae";
            no_anim = true;
            dim_around = true;
            blur = true;
            ignore_alpha = 0;
          }

        ];

        bind = mkBinds (
          [
            # Move focus
            [
              "SUPER+H"
              (focus "l")
            ]
            [
              "SUPER+L"
              (focus "r")
            ]
            [
              "SUPER+K"
              (focus "u")
            ]
            [
              "SUPER+J"
              (focus "d")
            ]
            # Move window
            [
              "SUPER+SHIFT+H"
              (move "l")
            ]
            [
              "SUPER+SHIFT+L"
              (move "r")
            ]
            [
              "SUPER+SHIFT+K"
              (move "u")
            ]
            [
              "SUPER+SHIFT+J"
              (move "d")
            ]
            # Window actions
            [
              "SUPER+Escape"
              close
            ]
            [
              "SUPER+X"
              kill
            ]
            [
              "SUPER+F"
              fullscreen
            ]
            # Applications
            [
              "SUPER+Slash"
              (exec "firefox")
            ]
            [
              "SUPER+Return"
              (exec "kitty -1")
            ]
            [
              "SUPER+G"
              (exec "game-picker")
            ]
            [
              "SUPER+0"
              (exec "rofi_power")
            ]
            [
              "SUPER+D"
              (exec "vicinae toggle")
            ]
            [
              "SUPER+S"
              (exec "wayscriber -a --freeze")
            ]
            [
              "SUPER+V"
              (exec "vicinae deeplink vicinae://launch/clipboard/history")
            ]
            [
              "SUPER+semicolon"
              (exec "vicinae deeplink vicinae://launch/core/search-emojis")
            ]
            [
              "SUPER+Z"
              (luaf ''
                local current = hl.get_config("cursor.zoom_factor")
                local next_zoom = current == 1.0 and 3.0 or 1.0
                hl.config({ cursor = { zoom_factor = next_zoom } })
              '')
            ]
            # Audio
            [
              "XF86AudioMute"
              (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
              { locked = true; }
            ]
            [
              "XF86AudioMicMute"
              (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
              { locked = true; }
            ]
            # Repeating volume/brightness
            [
              "XF86AudioLowerVolume"
              (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
              {
                repeating = true;
                locked = true;
              }
            ]
            [
              "XF86AudioRaiseVolume"
              (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
              {
                repeating = true;
                locked = true;
              }
            ]
            [
              "XF86MonBrightnessUp"
              (exec "brightnessctl -set 10%+")
              { repeating = true; }
            ]
            [
              "XF86MonBrightnessDown"
              (exec "brightnessctl -set 10%-")
              { repeating = true; }
            ]

            [
              "switch:on:Lid Switch"
              (luaf "hl.monitor{output='eDP-1',  disabled=true}")
              { locked = true; }
            ]
            #
            # [
            #   "switch:off:Lid Switch"
            #   (luaf "hl.monitor{output = 'eDP-1', disabled = false, scale = 1.0, position = 'auto', mode = 'preferred'}")
            #   { locked = true; }
            # ]

            [
              "XF86Display"
              (luaf "hl.monitor{output='eDP-1',  disabled=not not hl.get_monitor('eDP-1')}")
              { locked = true; }
            ]

            [
              "XF86AudioMedia"
              (luaf "hl.monitor{output='eDP-1',  disabled=not not hl.get_monitor('eDP-1')}")
              { locked = true; }
            ]

            # Mouse binds
            [
              "SUPER+mouse:272"
              (lua "hl.dsp.window.drag()")
              { mouse = true; }
            ]
            [
              "SUPER+mouse:273"
              (lua "hl.dsp.window.resize()")
              { mouse = true; }
            ]

            # [
            #   "mouse:277"
            #   (exec "hyprctl dispatch overview:toggle")
            # ]
          ]
          ++ workspaceBindings
        );

      };
      # extraConfig = builtins.readFile ./hyprland_monitor_manager.lua;
    };

  home.packages = [
    pkgs.bibata-hyprcursor
    pkgs.wayscriber
    pkgs.slurp
    pkgs.grim
  ];

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
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

  services.hyprpolkitagent.enable = true;
  services.hypridle = {
    enable = false; # Whe are using noctalia
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener =
        let
          mins = x: builtins.floor (x * 60);
        in
        [
          {
            timeout = mins 5;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = mins 5.5;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = mins 10;
            on_timeout = "systemctl suspend";
          }
        ];
    };
  };

  systemd.user.services.hyprland-monitor-manager = {
    Unit = {
      Description = "Hyprland Monitor Manager";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.python3} ${./monman.py}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.swaybg-wallpaper = {
    Unit = {
      Description = "Set wallpaper with swaybg";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${lib.getExe pkgs.swaybg} -i /home/leiserfg/wall.png -m fill";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
