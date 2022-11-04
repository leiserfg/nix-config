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
  ];

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "dunkel";
  services.openssh.enable = true;
  system.stateVersion = "22.05";
}
