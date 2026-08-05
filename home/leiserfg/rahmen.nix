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
    pixieditor
    #pgcli
    # poetry
    # blender-hip
    # gamescope
    # unstablePkgs.godot_4
    # godot
    # mindustry-wayland
    # nushell
    # ghostty
    # audacity
    ddcutil

    # playwright-test
    # anki
    # sunvox
    orca-c

    # myPkgs.tola

    steam
    # scrcpy
    llama-cpp-vulkan
  ];

  # home.sessionVariables = {
  #   PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers-chromium;
  #   PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  # };

  services.tailscale-systray.enable = true;

}
