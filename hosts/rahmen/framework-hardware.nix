{
  pkgs,
  input,
  ...
}: {
  # boot.kernelParams = [
  #   # For Power consumption
  #   # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
  #   "mem_sleep_default=deep"
  #   # For Power consumption
  #   # https://community.frame.work/t/linux-battery-life-tuning/6665/156
  #   "nvme.noacpi=1"
  # ];

  # This enables the brightness and airplane mode keys to work
  # https://community.frame.work/t/12th-gen-not-sending-xf86monbrightnessup-down/20605/11
  # boot.blacklistedKernelModules = ["hid-sensor-hub"];

  # For fingerprint support
  services.fprintd.enable = true;

  # Custom udev rules
  # services.udev.extraRules = ''
  #   # Fix headphone noise when on powersave
  #   # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
  #   SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
  #   # Ethernet expansion card support
  #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
  # '';

  # Mis-detected by nixos-generate-config
  # https://github.com/NixOS/nixpkgs/issues/171093

  # https://wiki.archlinux.org/title/Framework_Laptop#Changing_the_brightness_of_the_monitor_does_not_work
  hardware.acpilight.enable = true;

  # https://community.frame.work/t/resolved-graphical-artifacts-when-waking-up-from-hibernation-or-hybrid-sleep/39154
  boot.kernelParams = ["amdgpu.sg_display=0"];
}
