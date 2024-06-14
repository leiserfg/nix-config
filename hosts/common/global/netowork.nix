{pkgs, ...}: {
  hardware.bluetooth.enable = true;

  services.tailscale.enable = true;

  networking = {
    networkmanager = {
        enable = true;
        insertNameservers= ["100.100.100.100"];
    };


    useDHCP = false;
    firewall.enable = false;
  };


}
