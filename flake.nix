{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-hypr.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #last revision with yuzu   b8697e57f10292a6165a20f03d2f42920dfaf973
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nix-gaming.url = "github:fufexan/nix-gaming";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    leiserfg-overlay.url = "github:leiserfg/leiserfg-overlay";
    blender.url = "github:edolstra/nix-warez?dir=blender";
    blender.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
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



    nixpkgsHypr = forAllSystems (
      system:
        import inputs.nixpkgs-hypr {
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

      dunkel = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {
          inherit inputs;
          unstablePkgs = unstablePackages.x86_64-linux;
        };
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./hosts/dunkel
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
            ./hosts/rahmen
          ];
      };
    };

    homeConfigurations = {
      "leiserfg@shiralad" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          unstablePkgs = unstablePackages.x86_64-linux;
          codeium = inputs.codeium.packages.x86_64-linux;
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
          gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          unstablePkgs = unstablePackages.x86_64-linux;
          nixpkgsHypr = nixpkgsHypr.x86_64-linux;
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
          gamingPkgs = inputs.nix-gaming.packages.x86_64-linux;
          myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
          nixpkgsHypr = nixpkgsHypr.x86_64-linux;
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
