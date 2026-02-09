{
  pkgs,
  input,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/users/leiserfg.nix
    ../common/features/hyprland.nix
    ../common/features/docker.nix
    ../common/features/laptop.nix
  ];

  programs.dconf.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "rahmen";

  # hardware.framework.laptop13.audioEnhancement.enable = true;

  # finger cross to this workarounding mesa issues
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" ];

  powerManagement = {
    powerDownCommands = ''
      echo "0 0 1 0 0 0" > /sys/class/leds/chromeos\:multicolor\:charging/multi_intensity && echo "60" > /sys/class/leds/chromeos\:multicolor\:charging/brightness
    '';
    powerUpCommands = ''
      echo "chromeos-auto" > /sys/class/leds/chromeos\:multicolor\:charging/trigger
    '';
  };

  systemd.services.set-charge-limit = {
    description = "Set battery charge limit";
    after = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      # ExecStart = "${lib.getExe pkgs.bash} -c 'echo 100 > /sys/class/power_supply/BAT1/charge_control_end_threshold'";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'";
      RemainAfterExit = true;
    };

    # This ensures the service runs at startup
    wantedBy = [ "multi-user.target" ];
  };
}
