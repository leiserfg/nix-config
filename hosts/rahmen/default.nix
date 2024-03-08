{
  pkgs,
  input,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./framework-hardware.nix
    ../common/global
    ../common/users/leiserfg.nix
    # ../common/features/sway.nix
    ../common/features/hyprland.nix
    # ../common/features/x11.nix
  ];

  hardware.cpu.amd.updateMicrocode = true;

  services.udev.extraRules = ''
    # USB SWITCH as kvm
    # Bus 001 Device 071: ID 05e3:0610 Genesys Logic, Inc. Hub
    # Set input to 0x11  (HDMI 1)

    ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="05e3", ENV{ID_MODEL_ID}=="0610", RUN+="${pkgs.ddcutil}/bin/ddcutil setvcp 60 0x11"
  '';

  networking.hostName = "rahmen";


  virtualisation.waydroid.enable = true;
}
