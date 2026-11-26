{
  pkgs,
  myPkgs,
  ...
}:
{
  home.packages = [
    myPkgs.luciole
    pkgs.tree
  ];
  home.file.".local/share/luciole/scripts/send-to-telegram".source =
    pkgs.writeShellScript "send-to-telegram" ''
      Telegram -sendpath "$@"
    '';

  xdg.portal = {
    extraPortals = [ myPkgs.luciole ];
    config.common = {
      "org.freedesktop.impl.portal.FileChooser" = [
        "luciole"
        "gtk"
      ];
    };
  };
}
