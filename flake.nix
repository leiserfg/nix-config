{
  description = "My nix config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # neovim-nightly = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
    leiserfg-overlay.url = "github:leiserfg/leiserfg-overlay";
    blender.url = "github:edolstra/nix-warez?dir=blender";
    blender.inputs.nixpkgs.follows = "nixpkgs";

     # hypr.url = "git+https://github.com/leiserfg/Hyprland?submodules=1";

    # MASTER
     # hypr.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&rev=3c0605c68e50416819fea471a8fbef05e4a18684";

     hypr.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&rev=b6e226c3200276978e487a68a16fd696fcb7e7c8";

# d8b865366af9d5ed30d2ee0a437b9a3ed43c10bd
# 3852418d2446555509738bf1486940042107afe7    factorio works

# c4d214c42d743a69f606ff476b7266b3ace7d70e     factorio works
# a0b2169ed600b71627188dcd208b26911da8d583     factorio works
# 7188ee4f992966c5793efebd6dc70ab377820066     Multimonitor fails, factorio works
# 5d4b54b01286c10d4b6bf402a772b5938b054ce6  # BORKED Multimonitor
# b6e226c3200276978e487a68a16fd696fcb7e7c8      OK

    # hypr.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
     # hypr.url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=v0.44.0";

    hypr.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = {
    nixos-hardware,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      # "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];

    unstablePackages = forAllSystems (
      system:
        import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in rec {
    overlays = {
      default = import ./overlay {inherit inputs;};
    };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # Devshell for bootstrapping
    # Accessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix {};
    });

    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays =
            (builtins.attrValues overlays)
            ++ [
              inputs.blender.overlays.default
            ];
          config.allowUnfree = true;
          config.permittedInsecurePackages = [];
        }
    );

    nixosConfigurations = {
      shiralad = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs;
          unstablePkgs = unstablePackages.x86_64-linux;
        };
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./hosts/shiralad
          ];
      };

      rahmen = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs;
          unstablePkgs = unstablePackages.x86_64-linux;
        };
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            nixos-hardware.nixosModules.framework-13-7040-amd
            ./hosts/rahmen
          ];
      };
    };

    homeConfigurations = {
      "leiserfg@shiralad" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          # gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          unstablePkgs = unstablePackages.x86_64-linux;
          # neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
        };
        modules =
          (builtins.attrValues homeManagerModules)
          ++ [
            ./home/leiserfg/shiralad.nix
          ];
      };

      "leiserfg@rahmen" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          # gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          unstablePkgs = unstablePackages.x86_64-linux;
          # neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
          hyprPkgs = inputs.hypr.packages.x86_64-linux;
        };
        modules =
          (builtins.attrValues homeManagerModules)
          ++ [
            ./home/leiserfg/rahmen.nix
          ];
      };

      "leiserfg@dunkel" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          unstablePkgs = unstablePackages.x86_64-linux;
          # gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          # neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
          hyprPkgs = inputs.hypr.packages.x86_64-linux;
        };
        modules =
          (builtins.attrValues homeManagerModules)
          ++ [
            ./home/leiserfg/dunkel.nix
          ];
      };
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
