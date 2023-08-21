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

  boot.kernel.sysctl."vm.max_map_count" = 544288;

  hardware.cpu.amd.updateMicrocode = true;
  # high-resolution display
  nixpkgs.hostPlatform.system = "x86_64-linux";

  /* hardware.sane.enable = true; */
  # hardware.sane.extraBackends = [ pkgs.epkowa ];

  # hardware.sane.extraBackends = [ pkgs.utsushi  pkgs.epkowa ];
  # services.udev.packages = [ pkgs.utsushi ];
}
