{
  pkgs,
  lib,
  myPkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };

  noctalia-config = {
    audio.enable_overdrive = true;
    bar.default = {
      start = [
        "taskbar"
        "media"
      ];
      center = [ "active_window" ];
      end = [
        "tray"
        "notifications"
        "clipboard"
        "network"
        "bluetooth"
        "volume"
        "brightness"
        "battery"
        "control-center"
        "session"
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
    location.auto_locate = true;
    noctalia_state.setup_wizard_completed = true;
    shell = {
      corner_radius_scale = 0.0;
      clipboard_enabled = false;
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
    };
  };

  noctalia-settings = tomlFormat.generate "noctalia-settings.toml" noctalia-config;
in
{
  home = {
    packages = with pkgs; [

    ];
  };
  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia Shell - Wayland desktop shell";
      Documentation = "https://docs.noctalia.dev";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
      X-Restart-Triggers = [ noctalia-settings ];
    };

    Service = {
      ExecStart = "${lib.getExe myPkgs.noctalia_5}";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Optionally, create a symlink to the settings file in a known location
  home.file.".config/noctalia/settings.toml".source = noctalia-settings;

}
