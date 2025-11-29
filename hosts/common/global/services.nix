# This file (and the global directory) holds config that i use on all hosts
{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
{
  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    gvfs.enable = true;

    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };

    openssh.enable = true;
    dbus.implementation = "broker";
    upower.enable = true;

    tuned.enable = true;
    tlp.enable = false;

    keyd = {
      enable = true;
      keyboards = {
        piantor = {
          ids = [ "239a:102e" ];
        };
        akko = {
          ids = [ "0c45:7638" ];
          settings = {
            main = {
              capslock = "overload(control, esc)";
              esc = "`";
              "`" = "capslock";
            };
          };
        };
        laptop = {
          ids = [ "*" ];
          settings = {
            main = {
              capslock = "overload(control, esc)";
            };
          };
        };
      };
    };
  };

  # Make sure touchpad is disabled with keyd
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';


}
