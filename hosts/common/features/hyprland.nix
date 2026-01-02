{
  lib,
  pkgs,
  inputs,
  outputs,
  unstablePkgs,
  ...
}:
{

  security.pam.services.hyprlock = { };

  services.greetd = {
    enable = true;
    settings =
      let
        command = "start-hyprland";
        user = "leiserfg";
      in
      {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --cmd ${command} --user-menu --remember";
          user = "greeter";
        };

        initial_session = {
          command = command;
          user = user;
        };
      };
  };

}
