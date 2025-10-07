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
    udev.packages = [
      pkgs.android-udev-rules
    ];
    dbus.implementation = "broker";
    upower.enable = true;
    # power-profiles-daemon.enable = true;

    tuned.enable = true;
    tlp.enable = false;

    keyd = {
      enable = true;
      keyboards = {
        piantor = {
          ids = [ "239a:102e" ];
        };
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              capslock = "overload(ctrl_vim,esc)";
            };
            "ctrl_vim:C" = {
              # space = "swap(vim_mode)";
            };

            # "vim_mode:C" = {
            #   space = "swap(vim_mode)";
            #   h = "left";
            #   j = "down";
            #   k = "up";
            #   l = "right";
            #   # forward "word";
            #   w = "C-right";
            #   # backward "word";
            #   b = "C-left";
            # };
          };
        };
      };
    };
    interception-tools =
      let
        intercept = "${pkgs.interception-tools}/bin/intercept";
        caps2esc = "${
          (pkgs.interception-tools-plugins.caps2esc.overrideAttrs {
            patchPhase = ''
              ls .
              sed s/3.0/3.5/ -i ./CMakeLists.txt
              cat ./CMakeLists.txt
            '';
          })
        }/bin/caps2esc";
        uinput = "${pkgs.interception-tools}/bin/uinput";
      in
      {
        enable = false;
        udevmonConfig = ''
          - JOB: ""
            DEVICE:
              NAME: .*Leiser.*
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
          - JOB: "${intercept} -g $DEVNODE | ${caps2esc} -m 2 | ${uinput} -d $DEVNODE"
            DEVICE:
              NAME: .*Akko.*
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
          # Laptop
          - JOB: "${intercept} -g $DEVNODE | ${caps2esc} | ${uinput} -d $DEVNODE"
            DEVICE:
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
        '';
      };
  };

}
