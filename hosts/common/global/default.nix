# This file (and the global directory) holds config that i use on all hosts
{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./audio.nix
    ./fs.nix
    ./boot.nix
    ./games.nix
    ./gl.nix
    ./locale.nix
    ./netowork.nix
    ./nfs.nix
    ./nix.nix
    ./services.nix
    ./x11.nix
  ];
  # ++ (builtins.attrValues outputs.nixosModules);
  environment = {
    loginShellInit = ''
      # Activate home-manager environment, if not already
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';

    # Add terminfo files
    enableAllTerminfo = true;
  };

  # Allows users to allow others on their binds
  programs.fuse.userAllowOther = true;

  hardware.enableRedistributableFirmware = true;

  programs.fish.enable = true;
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    vim
  ];
}
