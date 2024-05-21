{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "thunderbolt"];
  boot.kernelModules = ["kvm-amd" "i2c-dev"];
  boot.initrd.kernelModules = ["amdgpu"];

  boot.kernel.sysctl."vm.max_map_count" = 544288;

  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.hostPlatform.system = "x86_64-linux";

  boot.initrd.luks.devices."luks-464cbf68-943f-4202-a078-da58d76a4219".device = "/dev/disk/by-uuid/464cbf68-943f-4202-a078-da58d76a4219";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/740974a9-5b78-4376-a3a9-72f085550433";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-170d4f89-ebb7-4e2a-a94f-e1b501e490b3".device = "/dev/disk/by-uuid/170d4f89-ebb7-4e2a-a94f-e1b501e490b3";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DB3D-712E";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/3c74134f-280b-4f0f-8020-fe0107783c96";}
  ];
}
