{pkgs, ...}: {
  hardware.bluetooth.enable = true;

  services.tailscale.enable = true;
  services.resolved.enable = true;
  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      # insertNameservers = ["1.1.1.1"];
      # appendNameservers = ["100.100.100.100"];
      wifi.backend = "iwd";
      dns = "systemd-resolved";
    };

    useDHCP = false;
    firewall.enable = false;
  };
}
