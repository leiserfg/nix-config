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
    settings = {
      default_session.command = "true"; # skip the greeter
      initial_session = {
        command = "Hyprland";
        user = "leiserfg";
      };
    };
  };

}
