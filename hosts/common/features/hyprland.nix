{
  lib,
  pkgs,
  inputs,
  outputs,
  unstablePkgs,
  ...
}: {
  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      unstablePkgs.xdg-desktop-portal-hyprland
    ];
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
