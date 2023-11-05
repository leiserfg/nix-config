{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}: {

  boot = {
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./xpad {})
    ];
  };
  services = {
    udev.extraRules = ''
      ACTION=="add", \
      	ATTRS{idVendor}=="2dc8", \
      	ATTRS{idProduct}=="3106", \
      	RUN+="${pkgs.kmod}/bin/modprobe xpad", \
      	RUN+="${pkgs.bash}/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'"
    '';
  };
}
