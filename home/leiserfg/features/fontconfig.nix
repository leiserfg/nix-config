{ ... }: {
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";
  };

  # home.sessionVariables = {
  #   FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  # };
}
