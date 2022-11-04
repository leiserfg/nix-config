{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-partition".device = "/dev/disk/by-label/luks-partition";

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];
}
