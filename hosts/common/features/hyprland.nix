{
  lib,
  pkgs,
  inputs,
  outputs,
  unstablePkgs,
  ...
}: {

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};
  environment.systemPackages = with pkgs; [
    swaylock
  ];
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --user-menu --remember";
        user = "greeter";
      };
    };
  };
}
