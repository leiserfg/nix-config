# This file (and the global directory) holds config that i use on all hosts
{
  lib,
  inputs,
  outputs,
  ...
}: {
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
    displayManager = {
      lightdm.enable = true;
    };
    windowManager.tinywm.enable = true;
  };
  programs.dconf.enable = true;
}
