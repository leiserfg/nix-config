{
  pkgs,
  unstablePkgs,
  lib,
  hyprPkgs,
  config,
  ...
}:
{
  imports = [
    ./_wayland_common.nix
    ./_waybar.nix
  ];

  # _module.args.wm = "niri";

  home.packages = [
    pkgs.niri
  ];

  wayland.windowManager.niri = {

    enable = true;
    spawnAtStartup = [
      [
        # Force the start as xdg-portal is not helping
        "systemctl"
        "--user"
        "start"
        "xdg-desktop-portal-gnome"
      ]
    ];
    settings = {
      prefer-no-csd = [];
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            variant = "altgr-intl";
          };
        };
        touchpad = {
          tap = [ ];
          natural-scroll = [ ];
          dwt = [ ];
        };
      };
      binds = {
        "Mod+D".spawn = "rofi-launch";
        "Mod+Return".spawn = "kitty";
        "Mod+0".spawn = "rofi_power";
        "Super+Alt+L".spawn = "swaylock";
        "Ctrl+Alt+Delete".quit = [ ];

        "Mod+H".focus-column-left = [ ];
        "Mod+J".focus-window-down = [ ];
        "Mod+K".focus-window-up = [ ];
        "Mod+L".focus-column-right = [ ];

        "Mod+Shift+Slash".show-hotkey-overlay = [ ];

        "Mod+WheelScrollDown  cooldown-ms=150".focus-workspace-down = [ ];
        "Mod+WheelScrollUp  cooldown-ms=150".focus-workspace-up = [ ];
        "Mod+Ctrl+WheelScrollDown cooldown-ms=150".move-column-to-workspace-down = [ ];
        "Mod+Ctrl+WheelScrollUp   cooldown-ms=150".move-column-to-workspace-up = [ ];

        "Mod+WheelScrollRight".focus-column-right = [ ];
        "Mod+WheelScrollLeft".focus-column-left = [ ];
        "Mod+Ctrl+WheelScrollRight".move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft ".move-column-left = [ ];

        "Mod+Escape".close-window = [ ];
        "Mod+F".fullscreen-window = [ ];

      };
    };
  };
}
