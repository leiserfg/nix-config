{ pkgs, ... }:
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps =
    let
      editor = "nvim.desktop";
      browser = "firefox.desktop";
    in
    {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/terminal" = "kitty.desktop";
        "x-scheme-handler/tg" = "telegram.desktop";
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "text/html" = browser;
        "text/*" = editor;
        "application/x-subrip" = editor;
        # "application/pdf" = "org.pwmt.zathura.desktop";
        "application/pdf" = "sioyek.desktop";
        "application/epub+zip" = "sioyek.desktop";
        # "application/epub+zip" = "org.pwmt.zathura.desktop";
        "image/*" = "imv.desktop";
      };
    };

  xdg.configFile."wireplumber/wireplumber.conf.d/10-bluetooth.conf".text = ''
    wireplumber.settings = {
       bluetooth.autoswitch-to-headset-profile = false
    }
  '';

  xdg.configFile."handlr/handlr.toml".source = (pkgs.formats.toml { }).generate "handlr.toml" {
    enable_selector = true;
    selector = "vicinae dmenu";
    handlers = [
      {
        regexes = [ "^.*.gif$" ];
        exec = "mpv --loop %U";
        terminal = false;
      }
      {
        regexes = [ "^.*.sunvox$" ];
        exec = "sunvox %f";
        terminal = false;
      }
      {
        exec = "mpv %U";
        regexes = [ "^https?://(www.)?youtube.com/watch\?v=.*$" ];
        terminal = false;
      }
    ];
  };
}
