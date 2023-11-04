# This file (and the global directory) holds config that i use on all hosts
{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  programs.dconf.enable = true;

  services.greetd = {
    enable = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway --user-menu --remember";
        user = "greeter";
      };
    };
  };
}
