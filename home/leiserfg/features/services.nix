{ lib, pkgs, ... }:
{
  services = {
    gpg-agent.enable = true;

    mpris-proxy.enable = true;
    network-manager-applet.enable = true;
    tailscale-systray.enable = true;

    # These are disabled cause we are now using a noctalia plugin
    udiskie = {
      enable = false;
      automount = true;
    };
    blueman-applet.enable = false;
  };

  systemd.user.services.telegram-desktop = {
    Unit = {
      Description = "Telegram Desktop";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.telegram-desktop}";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
