{
  description = "My nix config";

  inputs = {

    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    nixpkgs-unstable.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    leiserfg-overlay.url = "github:leiserfg/leiserfg-overlay";
    blender.url = "github:edolstra/nix-warez?dir=blender";
    blender.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    # run0-sudo-shim = {
    #   url = "github:lordgrimmauld/run0-sudo-shim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprland = {
    #   url = "github:leiserfg/Hyprland";
    # };

    # vicinae.url = "github:vicinaehq/vicinae";

  };

  outputs =
    {
      nixos-hardware,
      nixpkgs,
      home-manager,
      # vicinae,
      ...
    }@inputs:
    let
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
    in
    rec {
      overlays = {
        default = import ./overlay { inherit inputs; };
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
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });

      legacyPackages = forAllSystems (
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = (builtins.attrValues overlays) ++ [
            inputs.blender.overlays.default
          ];
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ ];
        }
      );

      nixosConfigurations =
        let
          common-mods = (builtins.attrValues nixosModules) ++ [
            # inputs.run0-sudo-shim.nixosModules.default
          ];
        in
        {
          shiralad = nixpkgs.lib.nixosSystem {
            pkgs = legacyPackages.x86_64-linux;
            specialArgs = {
              inherit inputs;
              unstablePkgs = unstablePackages.x86_64-linux;
            };
            modules = common-mods ++ [
              ./hosts/shiralad
            ];
          };

          rahmen = nixpkgs.lib.nixosSystem {
            pkgs = legacyPackages.x86_64-linux;
            specialArgs = {
              inherit inputs;
              unstablePkgs = unstablePackages.x86_64-linux;
            };
            modules = common-mods ++ [
              nixos-hardware.nixosModules.framework-13-7040-amd
              ./hosts/rahmen
            ];
          };

          dunkel = nixpkgs.lib.nixosSystem {
            pkgs = legacyPackages.x86_64-linux;
            specialArgs = {
              inherit inputs;
              unstablePkgs = unstablePackages.x86_64-linux;
            };
            modules = common-mods ++ [
              nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
              ./hosts/dunkel
            ];
          };
        };
      homeConfigurations =
        let
          common-mods = (builtins.attrValues homeManagerModules) ++ [
            # vicinae.homeManagerModules.default
            # { services.vicinae.enable = true; }
          ];
          extra-args = {
            inherit inputs;
          }
          // {
            myPkgs = inputs.leiserfg-overlay.packages.x86_64-linux;
            unstablePkgs = unstablePackages.x86_64-linux;
            neovimPkgs = inputs.neovim-nightly.packages.x86_64-linux;
          };
        in
        {
          "leiserfg@shiralad" = home-manager.lib.homeManagerConfiguration {
            pkgs = legacyPackages.x86_64-linux;
            extraSpecialArgs = extra-args;
            modules = common-mods ++ [
              ./home/leiserfg/shiralad.nix
            ];
          };

          "leiserfg@rahmen" = home-manager.lib.homeManagerConfiguration {
            pkgs = legacyPackages.x86_64-linux;
            extraSpecialArgs = extra-args;
            modules = common-mods ++ [
              ./home/leiserfg/rahmen.nix
            ];
          };

          "leiserfg@dunkel" = home-manager.lib.homeManagerConfiguration {
            pkgs = legacyPackages.x86_64-linux;
            extraSpecialArgs = extra-args;
            modules = common-mods ++ [
              ./home/leiserfg/dunkel.nix
            ];
          };
        };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
