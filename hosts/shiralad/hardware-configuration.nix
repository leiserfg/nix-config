{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  nixpkgs.hostPlatform.system = "x86_64-linux";



  hardware.sane.enable = true;
  # hardware.sane.extraBackends = [ pkgs.epkowa ];

  # hardware.sane.extraBackends = [ pkgs.utsushi  pkgs.epkowa ];
  # services.udev.packages = [ pkgs.utsushi ];
}
