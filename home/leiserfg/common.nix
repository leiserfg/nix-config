{
  inputs,
  unstablePkgs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: rec {
  imports = [../../shared/nix.nix];
  home = {
    username = lib.mkDefault "leiserfg";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };
  };
  home.packages = with pkgs;
  with builtins;
  with lib; [
    /* (python310.withPackages (ps: */
    /*   with ps; [ */
    /*     python-lsp-black  */
    /*     pyls-isort */
    /*   ])) */

    util-linux
    podman
    cni-plugins
    (unstablePkgs.tdesktop)
    (unstablePkgs.fish)
    (unstablePkgs.ruff)
    (unstablePkgs.black)
    (unstablePkgs.nodePackages.pyright)

    neovim-unwrapped
    sumneko-lua-language-server
    pipenv
    sqlitebrowser
    # clangd
    clang-tools
    # llvmPackages.clang
    bc
    zk
    ffmpeg_5-full
    jq
    gcc
    usbutils
    wget
    nodePackages.npm
    blueman
    pcmanfm
    spaceFM
    xarchiver
    calibre
    # krita
    pinentry.qt
    (iosevka-bin.override {variant = "sgr-iosevka-term-ss07";})
    (unstablePkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    noto-fonts-emoji
    noto-fonts-cjk-sans
    noto-fonts
    lm_sensors
    darktable
    gimp
    (unstablePkgs.kitty)
    rofi
    picom
    awesome
    polkit_gnome

    sumneko-lua-language-server
    lsof
    file
    unrar
    aria2
    zpaq
    p7zip
    dfeet

    pavucontrol
    # tdesktop
    firefox
    zathura
    nsxiv
    xdragon
    arandr
    xcwd
    moreutils
    htop
    lf
    fzf
    bat
    zoxide
    ripgrep
    rustup
    rust-analyzer-unwrapped
    gnome.gnome-disk-utility
    mupdf
    quickemu
    rsync

    sshuttle
    autossh
    openssh

    # git stuff
    delta

    gh
    git
    git-standup
    git-absorb
    xsel
    patool
    stylua
    yadm
    cachix
    android-tools
    ncdu
    git-lfs
    clinfo

    docker-compose

    # My overlay
    git-branchless
    # wasm2luajit
    # godot4
    # glslviewer
    # armourpaint
    # nsxiv-extras
    # material-maker
    yt-dlp
  ];
  programs = {
    home-manager.enable = true;

    fzf.enable = true;
    lf.enable = true;
    mpv = {
      enable = true;
      scripts = [pkgs.mpvScripts.mpris];
    };
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  fonts.fontconfig.enable = true;
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      package = pkgs.lato;
      name = "Lato";
    };
    # cursorTheme = {
    #     package = pkgs.gnome.adwaita-icon-theme;
    #     name = "Adwaita";
    # };
  };

  qt.enable = true;
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMCMD = "kitty";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
    x11.enable = true;
    gtk.enable = true;
  };
  xsession = {
    enable = true;
    windowManager.command = "awesome";
  };

  services = {
    xsettingsd = {
      enable = true;
      settings = {
        "Xft/DPI" = 98304;
        "Xft/Antialias" = true;
        "Xft/HintStyle" = "hintfull";
        "Xft/Hinting" = true;
        "Xft/RGBA" = "none";
      };
    };

    gpg-agent.enable = true;
    unclutter.enable = true;

    caffeine.enable = true;
    udiskie = {
      enable = true;
      automount = true;
    };
    mpris-proxy.enable = true;

    picom = {
      enable = true;
      vSync = true;
      backend = "xr_glx_hybrid";
      settings = {
        # xrender-sync-fence = true;
      };
    };

    blueman-applet.enable = true;
    network-manager-applet.enable = true;

    pasystray.enable = true;
    flameshot.enable = true;
    # screen-locker = with pkgs; {
    #   enable = true;
    #   lockCmd = "${i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 5 pixel";
    # };
  };
  # Force Rewrite

  manual.manpages.enable = false; # Doc framework is broken, so let's stop updating this
  # xdg.enable = true ;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "x-scheme-handler/tg" = "telegram.desktop";
      "inode/directory" = "pcmanfm.desktop";
      "text/plain" = "neovim.desktop";
    };
  };
}
