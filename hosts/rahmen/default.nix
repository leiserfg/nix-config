{
  pkgs,
  input,
  config,
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
    ../common/features/tailscale.nix
  ];

  programs.dconf.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "rahmen";

  # hardware.framework.laptop13.audioEnhancement.enable = true;

  # finger cross to this workarounding mesa issues
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x10" ];

  boot.extraModprobeConfig = ''
    options cros_charge_control probe_with_fwk_charge_control=1
  '';

  powerManagement = {
    powerDownCommands = ''
      echo "0 0 1 0 0 0" > /sys/class/leds/chromeos\:multicolor\:charging/multi_intensity && echo "60" > /sys/class/leds/chromeos\:multicolor\:charging/brightness
    '';
    resumeCommands = ''
      echo "chromeos-auto" > /sys/class/leds/chromeos\:multicolor\:charging/trigger
    '';
  };

  systemd.services.set-charge-limit = {
    description = "Set battery charge limit";
    after = [ "multi-user.target" ];

    script = ''
      echo 60 > /sys/class/power_supply/BAT1/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # This ensures the service runs at startup
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [ pkgs.fw-ectool ];
}
