{ pkgs, ... }: {
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [
        "Noto Sans"
      ];
      # This is commented out cause iosevka looks to small at 12pt in the browser
      # monospace = [ "Iosevka Term SS15 Medium" ];
      emoji = [
        "Twitter Color Emoji"
      ];
    };
  };
  home.packages = [
    pkgs.twitter-color-emoji
    (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSS15"; })
  ];

  # home.sessionVariables = {
  #   FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  # };
}
