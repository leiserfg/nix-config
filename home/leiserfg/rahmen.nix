{
  pkgs,
  unstablePkgs,
  config,
  myPkgs,
  inputs,
  ...
}:
{
  imports = [
    ./common.nix
    ./features/hyprland.nix
    ./features/laptop.nix
    ./features/games.nix
    # ./features/daw.nix
  ];

  home.packages = with pkgs; [
    pgcli
    poetry
    # unstablePkgs.blender-hip
    gamescope
    love
    # unstablePkgs.godot_4
    nushell
    audacity
    ddcutil
    # moonlight-qt
    # gnome-network-displays
    # anki
    sunvox
    orca-c

    steam
    scrcpy

    ((unstablePkgs.llama-cpp.override { vulkanSupport = true; }).overrideAttrs (old: rec {
      version = "4875";
      src = pkgs.fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        tag = "b${version}";
        hash = "sha256-oCduKRXLr4Ej431sHM3vJ248uUO970T50Y+3BpBL9Do=";
        leaveDotGit = true;
        postFetch = ''
          git -C "$out" rev-parse --short HEAD > $out/COMMIT
          find "$out" -name .git -print0 | xargs -0 rm -rf
        '';
      };
    })

    )
  ];

  services = {
    grobi = {
      enable = config.xsession.enable;
      rules = [
        {
          name = "Home";
          outputs_connected = [ "DP-2" ];
          configure_single = "DP-2";
          primary = true;
          atomic = true;
          execute_after = [
            ''
              echo "Xft.dpi: 96" | ${pkgs.xorg.xrdb}/bin/xrdb -merge

            ''
          ];
        }
        {
          name = "Mobile";
          outputs_disconnected = [ "DP-2" ];
          configure_single = "eDP-1";
          primary = true;
          atomic = true;
          execute_after = [
            ''
              echo "Xft.dpi: 144" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
            ''
          ];
        }
      ];
    };

    shikane = {
      enable = true;
      settings = {
        profile = [
          {
            name = "left-docked";
            output = [
              {
                match = "eDP-1";
                enable = false;
              }
              {
                search = "/.*";
                enable = true;
                scale = 1.5;
                mode = "preferred";
              }
            ];
          }

          {
            name = "game-mode";
            output = [
              {
                match = "eDP-1";
                enable = false;
              }
              {
                search = "/.*";
                enable = true;
                mode = "1920x1080@60.00Hz";
                scale = 1;
              }
            ];
          }

          {
            name = "lonly";
            output = [
              {
                match = "eDP-1";
                enable = true;
                scale = 1.6;
              }
            ];
          }
        ];
      };
    };
  };
}
