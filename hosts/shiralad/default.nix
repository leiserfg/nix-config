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

  services.xserver.videoDrivers = ["nvidia"];
  hardware.cpu.amd.updateMicrocode = true;

  networking.hostName = "shiralad";
  services.openssh.enable = true;
  system.stateVersion = "22.05";
}
