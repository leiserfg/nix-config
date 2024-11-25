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
  hardware.cpu.amd.updateMicrocode = true;
  services.fprintd.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  networking.hostName = "dunkel";
}
