{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {

  boot.kernel.sysctl."vm.max_map_count" = 544288;
  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;


  boot.initrd.luks.devices."luks-6da56e17-12d1-4c3d-a78f-af60996305a4".device = "/dev/disk/by-uuid/6da56e17-12d1-4c3d-a78f-af60996305a4";

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44079cc8-b1e5-4f11-8a1f-67ddcf018528";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-1a2a45ea-f226-4971-810c-bae0bd42a726".device = "/dev/disk/by-uuid/1a2a45ea-f226-4971-810c-bae0bd42a726";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9294-03A5";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/b335c633-4a9c-4010-bb81-4fd188946604"; }
    ];

}
