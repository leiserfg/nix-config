{lib, ...}: {
  nix.settings = {
    auto-optimise-store = lib.mkDefault true;
    experimental-features = ["nix-command" "flakes" "repl-flake"];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://leiserfg.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "leiserfg.cachix.org-1:Xm2Z2mX79Bo6LMor9LoH+QGqRNasB++VVCNF0UJh9Fc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
}
