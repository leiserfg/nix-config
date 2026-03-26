{ pkgs, config, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    gtk4.theme = config.gtk.theme;

    font = {
      package = pkgs.inter;
      name = "Inter";
    };
    gtk2.enable = false;
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 16;
    x11.enable = true; # This is used also by Xwayland
    gtk.enable = true;
  };
}
