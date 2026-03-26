{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ ../../../shared/nix.nix ];

  programs.nh = {
    enable = true;
    flake = "/home/leiserfg/nix-config/";
    clean.enable = true;
    clean.extraArgs = "--keep-since 9d --keep 3";
  };
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      warn-dirty = false;
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
