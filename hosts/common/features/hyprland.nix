# This file (and the global directory) holds config that i use on all hosts
{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland];
  };

  environment.systemPackages = with pkgs; [
    swaylock
  ];
  services.greetd = {
    enable = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --user-menu --remember";
        user = "greeter";
      };
    };
  };
}
