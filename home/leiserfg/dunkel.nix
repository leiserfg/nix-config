{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [./common.nix ./features/mesa.nix ./features/hyprland.nix ./features/daw.nix];
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    terraform
    terraform-ls
    insomnia
    awscli2
    csvkit
    libreoffice
    pandoc
    unstablePkgs.godot_4

    (gnome3.gvfs)
    # This is so we don't have to change the config in debian
    (writeShellScriptBin "sway" ''
      .  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      exec Hyprland
    '')
  ];

  home.sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
  };

  services = {
    kanshi = {
      enable = true;

      profiles = {
        undocked = {
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.0;
              status = "enable";
            }
          ];
        };

        docked = {
          outputs = [
            {
              criteria = "DP-1";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      };
    };
  };
}
