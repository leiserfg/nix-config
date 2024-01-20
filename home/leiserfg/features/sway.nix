{
  pkgs,
  unstablePkgs,
  lib,
  ...
} @ inputs:
{
  imports = [./_wayland_common.nix   ./_waybar.nix ];

  _module.args.wm = "sway";
  wayland.windowManager.sway = lib.attrsets.recursiveUpdate {
    package = pkgs.sway.override {
      extraSessionCommands = ''
        # home-manager on non nixos stuff
        .  ~/.nix-profile/etc/profile.d/hm-session-vars.sh

        export MOZ_ENABLE_WAYLAND=1
        export XDG_SESSION_TYPE=wayland

        if command -v nvidia-smi >/dev/null 2>&1; then
          export XWAYLAND_NO_GLAMOR=1
          export WLR_RENDERER=vulkan
          export WLR_NO_HARDWARE_CURSORS=1
          export LIBVA_DRIVER_NAME=nvidia
          export GBM_BACKEND=nvidia-drm
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export WLR_NO_HARDWARE_CURSORS=1
        fi
      '';

      # Don't complain if it's nvidia (but it should not be)
      extraOptions = ["--unsupported-gpu"];
      withBaseWrapper = true;
      withGtkWrapper = true;
    };

    config = {
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "altgr-intl";
        };

        "type:touchpad" = {
          tap = "enabled";
        };
      };

      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };
      output = {
        "*" = {bg = "~/wall.png fill";};
      };

      assigns = {
        "1" = [
          {app_id = "^firefox$";}
        ];
        "4" = [
          {app_id = "^org.telegram.desktop$";}
        ];
      };
    };

    # exec_always ${pkgs.swayidle}/bin/swayidle -w timeout 60 'swaylock -f -c 000000' timeout 75 swaymsg output * dpms off resume swaymsg output * dpms on before-sleep swaylock -f -c 000000
    extraConfig = ''
      for_window [app_id="dragon"] sticky enable
      for_window [class="dragon"] sticky enable
      for_window [title="Picture-in-Picture"] sticky enable
    '';
  } (import ./i3-sway.nix inputs);
}
