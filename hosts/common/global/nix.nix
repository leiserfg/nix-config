{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  # imports = [ ../../../shared/nix.nix ];

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://leiserfg.cachix.org"
        # "https://nix-gaming.cachix.org"
        # "https://nyx.chaotic.cx"
        # "https://hyprland.cachix.org"
        # "http://localhost:5028" # our local cache
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "leiserfg.cachix.org-1:Xm2Z2mX79Bo6LMor9LoH+QGqRNasB++VVCNF0UJh9Fc="
        # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        # "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  programs.nh = {
    enable = true;
    flake = "/home/leiserfg/nix-config/";
    clean.enable = true;
    clean.extraArgs = "--keep-since 9d --keep 3";
  };
}
