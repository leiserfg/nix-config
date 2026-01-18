{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
{

  services = {

    speechd.enable = false;

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
          ids = [
            "239a:102e"
            "beeb:0001"
            "1d50:615e"  # default zmk
          ];
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

  services.kanata = {
    enable = false;
    keyboards = {
      internalKeyboard = {
        devices = [
          # Replace the paths below with the appropriate device paths for your setup.
          # Use `ls /dev/input/by-path/` to find your keyboard devices.
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
           caps tab d h j k l
          )
          (defvar
           tap-time 200
           hold-time 200
          )
          (defalias
           caps (tap-hold 200 200 esc lctl)
           tab (tap-hold $tap-time $hold-time tab (layer-toggle arrow))
           del del  ;; Alias for the true delete key action
          )
          (deflayer base
           @caps @tab d h j k l
          )
          (deflayer arrow
           _ _ @del left down up right
          )
        '';
      };
    };
  };
}
