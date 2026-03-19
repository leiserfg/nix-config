{
  lib,
  pkgs,
  myPkgs,
  inputs,
  unstablePkgs,
  config,
  ...
}:
{
  imports = [
    # Shared settings
    ../../shared/nix.nix

    # Feature modules
    ./features/fish.nix
    ./features/shell-tools.nix
    ./features/nu.nix
    ./features/cmds.nix
    ./features/mpv.nix
    ./features/git.nix
    ./features/kitty.nix
    ./features/noctalia.nix

    # New feature modules
    ./features/packages.nix
    ./features/services.nix
    ./features/scripts.nix
    ./features/xdg.nix
    ./features/gtk-qt.nix
    ./features/session.nix

    # Program-specific modules
    ./features/programs/cli.nix
    ./features/programs/firefox.nix
    ./features/programs/yazi.nix
    ./features/programs/vicinae.nix


    # Pi and nvim
    ./pi.nix
    ./nvim
  ];

  # disable news; they don't work well with flakes and message is anoying
  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };

  home = {
    username = lib.mkDefault "leiserfg";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "22.05";
  };

  nix = {
    enable = true;
    package = pkgs.nix;
  };

  home.shell = {
    # Let's make bash silly
    # enableBashIntegration = false;
  };

  manual.manpages.enable = false; # Doc framework is broken; so let's stop updating this
}