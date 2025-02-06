{
  pkgs,
  input,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/global
    ../common/users/leiserfg.nix
    ../common/features/hyprland.nix
    ../common/features/docker.nix
    # ../common/features/zswap.nix
  ];
  hardware.cpu.amd.updateMicrocode = true;
  services.fprintd.enable = true;

  networking.hostName = "dunkel";

  systemd.services.set-charge-limit = {
    description = "Set battery charge limit";
    after = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
      RemainAfterExit = true;
    };

    # This ensures the service runs at startup
    wantedBy = ["multi-user.target"];
  };
}
