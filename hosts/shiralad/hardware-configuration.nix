{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd" "i2c-dev"];

  boot.kernel.sysctl."vm.max_map_count" = 544288;

  hardware.cpu.amd.updateMicrocode = true;
  # high-resolution display
  nixpkgs.hostPlatform.system = "x86_64-linux";

  #SCANNER
  /*
  hardware.sane.enable = true;
  */
  # hardware.sane.extraBackends = [ pkgs.epkowa ];
  # hardware.sane.extraBackends = [ pkgs.utsushi  pkgs.epkowa ];
  # services.udev.packages = [ pkgs.utsushi ];

  hardware.nvidia = {
    # Modesetting is needed for most wayland compositors
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  services.udev.extraRules = ''
    # USB SWITCH as kvm
    # Bus 001 Device 071: ID 05e3:0610 Genesys Logic, Inc. Hub
    # Set input to 0x0f  (Display Port)

    ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="05e3", ENV{ID_MODEL_ID}=="0610", RUN+="${pkgs.ddcutil}/bin/ddcutil setvcp 60 0x0f"
  '';
}
