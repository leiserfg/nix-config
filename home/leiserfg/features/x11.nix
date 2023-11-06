{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    autorandr
    xsel
    arandr
    xorg.xrandr
    xorg.xev
    xcwd

    rofi
  ];

  xsession = {
    enable = true;
    windowManager.command = "qtile start";
  };

  xsettingsd = {
    enable = false;
    settings = {
      "Xft/DPI" = 98304;
      "Xft/Antialias" = true;
      "Xft/HintStyle" = "hintfull";
      "Xft/Hinting" = true;
      "Xft/RGBA" = "none";
    };
  };
  caffeine.enable = true;
  unclutter.enable = true;
  home.services = {
    flameshot.enable = false;
    picom = {
      enable = true;
      vSync = true;
      backend = "xr_glx_hybrid";
      settings = {
        # xrender-sync-fence = true;
      };
    };
  };
}
