# This file (and the global directory) holds config that i use on all hosts
{
  lib,
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      ./locale.nix
      ./nix.nix
      # ./openssh.nix
      # ./podman.nix
      # ./postgres.nix
      # ./sops.nix
      # ./ssh-serve-store.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);
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

  environment.systemPackages = with pkgs; [
    vim
  ];
}
