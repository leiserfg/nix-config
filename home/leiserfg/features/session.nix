{ pkgs, ... }:
{
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMCMD = "kitty";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MOZ_USE_XINPUT2 = "1";

    # Fix telegram input
    # ALSOFT_DRIVERS = "pulse";

    # Disable qt decoration for telegram
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # Make cargo use git to pull from github
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";

    # FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";

    # Force wayland for electron
    NIXOS_OZONE_WL = 1;

    # Fixes some qt programs crashing while using gtks file-dialog
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  };

  fonts.fontconfig.enable = true;
}
