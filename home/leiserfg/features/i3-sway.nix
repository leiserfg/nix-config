{pkgs, ...}: {
  enable = true;

  config = rec {
    modifier = "Mod4";
    # Use kitty as default terminal
    terminal = "kitty -1";

    focus = {
      followMouse = false;
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
      horizontal = 3;
      vertical = 3;
      inner = 3;
      outer = 3;
      left = 3;
      right = 3;
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

      "${modifier}+h" = "focus left";
      "${modifier}+j" = "focus down";
      "${modifier}+k" = "focus up";
      "${modifier}+l" = "focus right";
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
      "Mod4+g" = "exec game-picker";
      "Mod4+0" = "exec rofi_power";

      # "Print" = "exec ${pkgs.wayshot}/bin/wayshot -f /tmp/foo.png; exec sleep 1; exec ${pkgs.wl-clipboard}/bin/wl-copy -t image/png < /tmp/foo.png"; # TODO: would like to change the program for screenshots
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";
      "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer --allow-boost -i 5";
      "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer --allow-boost -d 5";
      "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute";
      "Mod4+Shift+i" = "move scratchpad";
      "Mod4+i" = "scratchpad show";
    };

    floating = {
      titlebar = false;
      criteria = [
        {window_role = "pop-up";}
        {window_role = "bubble";}
        {window_role = "task_dialog";}
        {window_role = "Preferences";}

        {window_type = "dialog";}
        {window_type = "menu";}
      ];
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
        command = "${pkgs.autotiling}/bin/autotiling";
        always = true;
      }
    ];
    menu = "rofi-pp";
    bars = [];
  };
}
