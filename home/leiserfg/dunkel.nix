{
  pkgs,
  unstablePkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./features/mesa.nix
    ./features/hyprland.nix
    ./features/daw.nix
  ];
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    pgcli
    pre-commit
    poetry
    insomnia
    awscli2
    csvkit
    libreoffice
    pandoc

    wabt # wasm-decompile
    luajit
    wasynth # wasm2luajit
    unstablePkgs.emscripten # emcc

    unstablePkgs.godot_4

    (gnome3.gvfs)
    # This is so we don't have to change the config in debian
    (writeShellScriptBin "sway" ''
      .  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      exec Hyprland
    '')
  ];

  services = {
    kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              scale = 1.0;
              status = "enable";
            }
          ];
        }

        {
          profile.name = "office";
          profile.outputs = [
            {
              criteria = "Dell Inc. DELL S2721QS 4N2CM43";
              mode = "2560x1440@59.95100";
              scale = 1.6;
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }

        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "DP-1";
              mode = "3840x2160";
              scale = 1.66666666;
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
      ];
    };
  };
}
