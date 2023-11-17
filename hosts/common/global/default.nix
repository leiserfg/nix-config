# This file (and the global directory) holds config that i use on all hosts
{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}: {
  imports =
    [
      ./audio.nix
      ./boot.nix
      ./games.nix
      ./gl.nix
      ./locale.nix
      ./netowork.nix
      ./nfs.nix
      ./nix.nix
      ./services.nix
      ./security.nix
    ];
    # ++ [lib.mkIf (lib.versionOlder config.boot.kernelPackages.kernel.version "6.5.7") ../common/features/8bitdo.nix];
  environment = {
    loginShellInit = ''
      # Activate home-manager environment, if not already
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';

    # Add terminfo files
    enableAllTerminfo = true;
  };

  system.stateVersion = "22.05";

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

  programs.dconf.enable = true;
  hardware.enableRedistributableFirmware = true;

  programs.fish.enable = true;
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];
}
