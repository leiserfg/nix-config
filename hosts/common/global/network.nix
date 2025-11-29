{ lib, pkgs, ... }:
{
  hardware.bluetooth.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };
  services.resolved.enable = true;
  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved";
    };
    useDHCP = false;

    firewall.enable = false;
  };

}
