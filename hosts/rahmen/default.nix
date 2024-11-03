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

  hardware.cpu.amd.updateMicrocode = true;
  networking.hostName = "rahmen";

}
