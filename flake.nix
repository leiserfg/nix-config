{
  description = "My nix config";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    leiserfg-overlay.url = "github:leiserfg/leiserfg-overlay";
    blender.url = "github:edolstra/nix-warez?dir=blender";
    blender.inputs.nixpkgs.follows = "nixpkgs";

       hypr.url = "git+https://github.com/leiserfg/Hyprland?submodules=1";
    # hypr.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

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
          neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
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
          neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
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
          neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
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
