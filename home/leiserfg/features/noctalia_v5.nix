{
  lib,
  ...
}:

{
  programs.noctalia = {
    enable = true;
    checkConfig = true;
    systemd.enable = true;
    settings = {
      audio.enable_overdrive = true;
      bar.default = {
        position = "right";
        center = [
          "taskbar"
        ];
        end = [
          # "active_window"
        ];
        start = lib.reverseList [
          "media"
          "tray"
          "notifications"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "control-center"
          # "session"
          "clock"
        ];
        margin_ends = 0;
        margin_edge = 0;
        padding = 0;
        radius = 0;
        thickness = 25;
      };
      brightness.enable_ddcutil = true;
      desktop_widgets.enabled = true;
      idle = {
        enable = true;
        idle_timeout = 300; # 5 minutes
        lock_timeout = 330; # 5.5 minutes
        suspend_timeout = 600; # 10 minutes
        behavior.lock = {
          action = "lock";
          enabled = true;
          timeout = 600;
        };
        behavior.lock-and-suspend = {
          action = "lock_and_suspend";
          enabled = false;
          timeout = 900;
        };
        behavior.screen-off = {
          action = "screen_off";
          enabled = true;
          timeout = 660;
        };
      };
      lockscreen = {
        blurred_desktop = true;
        fingerprint = false; # so it does not activate the fingerprint reader at lock screen already
        allow_empty_password = true; # this activates the reader on Enter key press
      };
      location.auto_locate = true;
      shell = {
        corner_radius_scale = 0.0;
        clipboard_enabled = false;
        screenshot.annotate = true;
      };
      theme = {
        mode = "dark";
        source = "builtin";
      };
      widget.media = {
        hide_when_no_media = true;
        max_length = 135;
        title_scroll = "on_hover";
      };
      widget.taskbar = {
        capsule_radius = 8.0;
        group_by_workspace = true;
        hide_empty_workspaces = false;
        show_all_outputs = true;
        workspace_label_placement = "inside";
        inactive_opacity = 0.7;
      };
    };

  };
}
