{
  pkgs,
  input,
  config,
  lib,
  ...
}: {
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./framework-hardware.nix
      ../common/global
      ../common/users/leiserfg.nix
      ../common/features/sway.nix
    ];

  hardware.cpu.amd.updateMicrocode = true;

  networking.hostName = "rahmen";
}
