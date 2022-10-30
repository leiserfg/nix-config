{pkgs, ...}: {
  hardware.bluetooth.enable = true;

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    firewall.enable = false;
  };
}
