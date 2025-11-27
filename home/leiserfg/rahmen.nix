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

    # (kdePackages.qtquickeffectmaker.overrideAttrs {
    #   postPatch = ''
    #     ls
    #      substituteInPlace ./tools/qqem/applicationsettings.cpp \
    #      --replace "QLibraryInfo::path(QLibraryInfo::QmlImportsPath)"  "QStringLiteral(\"$out/lib/qt-6/qml\")"
    #   '';
    # })

    # myPkgs.pixieditor
    pgcli
    # poetry
    # blender-hip
    gamescope
    # unstablePkgs.godot_4
    godot
    # nushell
    # ghostty
    # audacity
    ddcutil

    # playwright-test
    # anki
    sunvox
    # orca-c

    # myPkgs.tola

    # steam
    # scrcpy
    # (unstablePkgs.llama-cpp.override { vulkanSupport = true; })
  ];

  # home.sessionVariables = {
  #   PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
  #   PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  # };

  services = {
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
