{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
{
  networking.networkmanager.wifi.powersave = false;
  powerManagement = {
    powerDownCommands = "${pkgs.util-linux}/bin/rfkill block all";
    powerUpCommands = "${pkgs.util-linux}/bin/rfkill unblock all";
  };

  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"
  '';
}
