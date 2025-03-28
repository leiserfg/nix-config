{
  lib,
  pkgs,
  inputs,
  outputs,
  unstablePkgs,
  ...
}: {
  # xdg.portal = {
  #   enable = true;
  #   config.common.default = "*";
  #   # wlr.enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     unstablePkgs.xdg-desktop-portal-hyprland
  #   ];
  # };

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
