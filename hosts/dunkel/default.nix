{
  pkgs,
  input,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/global
    ../common/users/leiserfg.nix
    ../common/features/hyprland.nix
    ../common/features/docker.nix
    ../common/features/oom.nix
    ../common/features/zswap.nix
    ../common/features/laptop.nix
  ];
  hardware.cpu.amd.updateMicrocode = true;
  services.fprintd.enable = true;

  networking.hostName = "dunkel";

  systemd.services.set-charge-limit = {
    description = "Set battery charge limit";
    after = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
      RemainAfterExit = true;
    };

    # This ensures the service runs at startup
    wantedBy = [ "multi-user.target" ];
  };

  # Osquery service for Fleet MDM
  services.osquery = {
    enable = true;
    flags = {
      config_plugin = "tls";
      config_tls_endpoint = "/api/v1/osquery/config";
      config_refresh = "60";
      enroll_secret_path = "/var/lib/osquery/secret.txt";
      enroll_tls_endpoint = "/api/v1/osquery/enroll";
      logger_plugin = "tls";
      logger_tls_endpoint = "/api/v1/osquery/log";
      disable_distributed = "false";
      distributed_plugin = "tls";
      distributed_tls_read_endpoint = "/api/v1/osquery/distributed/read";
      distributed_tls_write_endpoint = "/api/v1/osquery/distributed/write";
      distributed_tls_max_attempts = "10";
      distributed_interval = "10";
      tls_hostname = "fleet.oneit.g1i.one";
      tls_server_certs = "/var/lib/osquery/certs.pem";
      host_identifier = "uuid";
    };
    settings = {
      options = { };
    };
  };
}
