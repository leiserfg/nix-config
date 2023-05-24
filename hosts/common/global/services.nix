# This file (and the global directory) holds config that i use on all hosts
{
  pkgs,
  inputs,
  outputs,
  ...
}: {
  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    /*
    chrony.enable = true;
    */

    gvfs.enable = true;
    ananicy.enable = true;
    udev.packages = [
      pkgs.android-udev-rules
    ];
    interception-tools = let
      intercept = "${pkgs.interception-tools}/bin/intercept";
      caps2esc = "${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc";
      uinput = "${pkgs.interception-tools}/bin/uinput";
    in {
      enable = true;
      udevmonConfig = ''
        - JOB: ""
          DEVICE:
            NAME: .*[Ff]erris.*
        - JOB: ""
          DEVICE:
            NAME: .*WeAct.*
        - JOB: "${intercept} -g $DEVNODE | ${caps2esc} -m 2 | ${uinput} -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
      '';
    };
  };
}
