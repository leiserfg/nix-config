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
    /* unstablePkgs.godot_4 */
    rink
    sunvox
    unstablePkgs.uiua
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
    gparted
    love



    rofi-wayland

    /* xdg-desktop-portal */
    /* xdg-desktop-portal-hyprland */
    inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland
    wev
    wl-clipboard
  ];
  programs.waybar = {
    enable = true;
    package = unstablePkgs.waybar;
    /* .overrideAttrs (oldAttrs: { */
    /*   mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"]; */
    /* }); */
    settings.mainbar.modules-left = ["hyprland/workspaces"];
    settings.mainbar.modules-center = ["hyprland/window"];
    settings.mainbar.modules-right = [
      "battery"
      "tray"
      "wireplumber"
      "clock"
      #  currently using applets
      # "network"
      /*
      "bluetooth"
      */
    ];
    settings.mainbar.layer = "top";
    settings.modules = {
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
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
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

        exec-once=waybar

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

    '';
  };
}
