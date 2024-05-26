# This file (and the global directory) holds config that i use on all hosts
{
  lib,
  inputs,
  outputs,
  ...
}: {
  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      xkbvariant = "altgr-intl";
    };
    displayManager = {
      lightdm.enable = true;
    };
    windowManager.tinywm.enable = true;
  };
}
