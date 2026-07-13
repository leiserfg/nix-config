{ lib, pkgs, ... }:
{
  services = {
    gpg-agent.enable = true;
    # ssh-agent.enable = true;
    mpris-proxy.enable = true;
    network-manager-applet.enable = true;
    tailscale-systray.enable = true;

    udiskie = {
      enable = true;
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

  systemd.user.services.rbw = {
    Unit = {
      Description = "Unofficial Bitwarden CLI Agent (Default Profile)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "exec";
      ExecStart = "${lib.getExe' pkgs.rbw "rbw-agent"} --no-daemonize";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
