{
  lib,
  pkgs,
  inputs,
  outputs,
  unstablePkgs,
  ...
}: {

  security.pam.services.hyprlock = {};
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
