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
    # ./features/niri.nix
    ./features/games.nix
    # ./features/daw.nix
  ];

  home.packages = with pkgs; [
    immich-go
    # (kdePackages.qtquickeffectmaker.overrideAttrs {
    #   postPatch = ''
    #     ls
    #      substituteInPlace ./tools/qqem/applicationsettings.cpp \
    #      --replace "QLibraryInfo::path(QLibraryInfo::QmlImportsPath)"  "QStringLiteral(\"$out/lib/qt-6/qml\")"
    #   '';
    # })

    ansel
    # darktable
    myPkgs.pixieditor
    #pgcli
    # poetry
    # blender-hip
    gamescope
    # unstablePkgs.godot_4
    godot
    mindustry-wayland
    # nushell
    # ghostty
    # audacity
    ddcutil

    # playwright-test
    # anki
    # sunvox
    orca-c

    # myPkgs.tola

    # steam
    # scrcpy
    myPkgs.llama-cpp-vulkan
    # (llama-cpp-vulkan.overrideAttrs (
    #   final: prev: {
    #     version = "8884";
    #     src = fetchFromGitHub {
    #       owner = "Indras-Mirror";
    #       repo = "llama.cpp-mtp";
    #       rev = "e2170c42ebb0fb7719e0ecc268826cd08f492e2b";
    #       hash = "sha256-bQQ4noE761NzBpxJMzoJD+ejMZUdX/gfmxcf2UaMipw=";
    #       leaveDotGit = true;
    #       postFetch = ''
    #         git -C "$out" rev-parse --short HEAD > $out/COMMIT
    #         find "$out" -name .git -print0 | xargs -0 rm -rf
    #       '';
    #     };
    #     npmDepsHash = "sha256-k62LIbyY2DXvs7XXbX0lNPiYxuYzeJUyQtS4eA+68f8=";
    #   }
    # ))
  ];

  # home.sessionVariables = {
  #   PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers-chromium;
  #   PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  # };

  services = {
    shikane = {
      # enable = true;
      settings = {
        profile = [
          {
            name = "left-docked-home";
            output = [
              {
                match = "eDP-1";
                enable = false;
              }
              {
                search = [
                  "m=DELL S2721QS"
                  "s=DY1CM43"
                  "v=Dell Inc."
                ];
                enable = true;
                scale = 1.5;
                mode = "3840x2160@60.00Hz";
              }
            ];
          }
          # {
          #   name = "left-docked";
          #   output = [
          #     {
          #       match = "eDP-1";
          #       enable = false;
          #     }
          #     {
          #       search = "/.*";
          #       enable = true;
          #       scale = 1.5;
          #       mode = "best";
          #     }
          #   ];
          # }
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
