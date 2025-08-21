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
  security.pam.services.swaylock = { };
  environment.systemPackages = with pkgs; [
    swaylock
  ];
  services.greetd = {
    enable = true;
    settings = {
      default_session =
        let
          tuigreet = "${lib.getExe pkgs.tuigreet}";
          tuigreetOptions = [
            "--remember"
            "--time"
            "--user-menu"
            # Make sure theme is wrapped in single quotes. See https://github.com/apognu/tuigreet/issues/147
            "--theme 'border=blue;text=cyan;prompt=green;time=red;action=blue;button=white;container=black;input=red'"
            "--cmd Hyprland"
          ];
          flags = lib.concatStringsSep " " tuigreetOptions;
        in
        {
          command = "${tuigreet} ${flags}";
          user = "greeter";
        };
    };
  };
}
