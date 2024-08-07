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
  # assertions = [
  #   {
  #     assertion = builtins.compareVersions nixpkgsHypr.hyprland.version unstablePkgs.hyprland.version >= 0;
  #     message = "We can remove hyprland override already ${nixpkgsHypr.hyprland.version} ${unstablePkgs.hyprland.version}";
  #   }
  # ];

  # This is for wayland
  _module.args.wm = "hyprland";

  services.kanshi.systemdTarget = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
    };

    # Fix for the monitor issue, input in gamescope still broken
    package = hyprPkgs.hyprland;

    # package = pkgs.hyprland.overrideAttrs (oldAttrs: {
    #   src = pkgs.fetchFromGitHub {
    #     owner = "hyprwm";
    #     repo = oldAttrs.pname;
    #     fetchSubmodules = true;
    #     rev = "eea0a6a";
    #     hash = "sha256-aaF2FYy152AvdYvqn7kj+VNgp07DF/p8cLmhXD68i3A=";
    #   };
    # });

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
            binde=,XF86MonBrightnessUp,   exec, ${pkgs.light}/bin/light -A 10
            binde=,XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 10
            # bind =,XF86AudioPlay,         exec, playerctl play-pause
            # bind =,XF86AudioPrev,         exec, playerctl previous
            # bind =,XF86AudioNext,         exec, playerctl next

            # Move/resize windows with mod + LMB/RMB and dragging
            bindm = $mod, mouse:272, movewindow
            bindm = $mod, mouse:273, resizewindow


             bind=$mod,f,fullscreen

             bind = $mod, Slash, exec, firefox
             bind = $mod, Return, exec, kitty -1

             bind = $mod,Print, exec, ${pkgs.grimblast}/bin/grimblast save output
             bind = $mod+SHIFT,Print, exec, ${pkgs.grimblast}/bin/grimblast save area
             bind = ,Print, exec, ${pkgs.grimblast}/bin/grimblast copy output
             bind = SHIFT,Print, exec, ${pkgs.grimblast}/bin/grimblast copy area

             bind = $mod, G, exec, game-picker
             bind = $mod, 0, exec, rofi_power
             bind = $mod, P, exec, rofi_power
             bind = $mod, D, exec, rofi-launch

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

          general {
              layout = master
              gaps_out = 4
          }

          cursor {
              inactive_timeout = 10
          }

          # misc {
          #     enable_swallow = true
          #     swallow_regex = ^(kitty)$
          # }

          gestures {
              workspace_swipe = true
              workspace_swipe_fingers = 4
          }

          master {
            no_gaps_when_only = 3
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
              }

          }

        #RULES
        windowrule = workspace 1,firefox
        windowrule = workspace 4,org.telegram.desktop
        windowrule = center,pavucontrol
        windowrule = float,pavucontrol
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
    '';
  };

  # exec-once = sleep 6 && shikane
  home.packages = [pkgs.swaybg];
  programs.hypridle = {
    enable = true;
    package = unstablePkgs.hypridle; # it's not in stable yet
    lockCmd = "pidof swaylock || swaylock -i ~/wall.png -f && sleep 3";

    # Stop automatic locking, I'm home-alone

    # beforeSleepCmd = "loginctl lock-session"; # lock before suspend.
    afterSleepCmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.

    listeners = [
      # {
      #   timeout = 5 * 60; # 5min
      #   onTimeout = "loginctl lock-session"; # lock screen when timeout has passed
      # }

      {
        timeout = builtins.floor (5.5 * 60); # 5.5min
        onTimeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        onResume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
      }
    ];
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    # wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      unstablePkgs.xdg-desktop-portal-hyprland
    ];
  };
}
