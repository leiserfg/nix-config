{
  pkgs,
  input,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../common/global
    ../common/global/fs.nix
    ../common/users/leiserfg.nix
    ../common/features/nvidia.nix
    # ../common/features/8bitdo.nix    # now builtin in linux 6.6
    ../common/features/sway.nix
  ];

  services.xserver.videoDrivers = ["nvidia"];
  hardware.cpu.amd.updateMicrocode = true;

  networking.hostName = "shiralad";
  services.openssh.enable = true;
  system.stateVersion = "22.05";

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

}
