{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [inputs.hardware.nixosModules.lenovo-thinkpad-p1-gen3];

  hardware.video.hidpi.enable = lib.mkDefault true;
  nixpkgs.hostPlatform.system = "x86_64-linux";
}
