{
  pkgs,
  input,
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/users/leiserfg.nix
    ../common/features/hyprland.nix
    ../common/features/docker.nix
  ];

programs.dconf.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "rahmen";
  hardware.framework.laptop13.audioEnhancement.enable = true;


  systemd.services.set-charge-limit = {
    description = "Set battery charge limit";
    after = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'";
      RemainAfterExit = true;
    };

    # This ensures the service runs at startup
    wantedBy = ["multi-user.target"];
  };
}
