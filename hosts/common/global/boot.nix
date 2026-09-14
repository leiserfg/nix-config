{
  pkgs,
  config,
  inputs,
  ...
}:
{
  boot = {
    # kernelPackages = pkgs.linuxPackages_6_12;

    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "amdgpu.dcdebugmask=0x410" ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [
      "hid-nintendo"
      "k10temp"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      zenpower
      # ddcci-driver
    ];

  };

  # Ideally this should be enough, but we can't use it cause upstream linux-firmware is borked
  # hardware.enableRedistributableFirmware = true;

  hardware.firmware = [
    inputs.nixpkgs-pinned.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linux-firmware
    pkgs.ipw2200-firmware
    pkgs.rtl8192su-firmware
    pkgs.rt5677-firmware
    pkgs.rtl8761b-firmware
    pkgs.zd1211fw
    pkgs.alsa-firmware
    pkgs.sof-firmware
    pkgs.libreelec-dvb-firmware

  ];
}
