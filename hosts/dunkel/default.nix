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
  ];
  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "dunkel";
}
