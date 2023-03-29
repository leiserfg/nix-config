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
    util-linux
    podman
    cni-plugins
    /* sioyek */
    gnumake
    (unstablePkgs.tdesktop)
    (unstablePkgs.fish)
    (unstablePkgs.ruff)
    (unstablePkgs.black)
    (unstablePkgs.bun)
    (unstablePkgs.nodePackages.pyright)
    /*
    (unstablePkgs.nushell)
    */
    /*
    (unstablePkgs.zoxide)
    */
    nodePackages.typescript-language-server
    vokoscreen-ng
    zoxide
    iredis
    /*
    luajit
    */
    doggo
    neovim-unwrapped
    sumneko-lua-language-server
    pipenv
    sqlitebrowser
    alejandra
    # clangd
    /*
    clang-tools
    */
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
    xarchiver
    calibre
    # krita
    pinentry.qt
    (unstablePkgs.iosevka-bin.override {variant = "sgr-iosevka-term-ss07";})
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
    /*
    awesome
    */
    qtile
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
    /*
    firefox
    */
    zathura
    nsxiv
    xdragon
    arandr
    xcwd
    moreutils
    htop
    lf
    fzf
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
    git-bug
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
    bat = {
      enable = true;
      config.theme = "base16";
    };
    firefox = {
      enable = true;
      /*
      package = pkgs.firefox.override {
      */
      /*
      cfg = {
      */
      /*
      enableTridactylNative = true;
      */
      /*
      };
      */
      /*
      };
      */
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
    MOZ_USE_XINPUT2 = "1";
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
    /*
    windowManager.command = "awesome";
    */
    windowManager.command = "qtile start";
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
    cbatticon = {
      enable = true;
      lowLevelPercent = 50;
      criticalLevelPercent = 30;
    };
    /*
    caffeine.enable = true;
    */
    udiskie = {
      enable = true;
      automount = true;
    };
    mpris-proxy.enable = true;
    dunst = {
      enable = true;
      settings = {
        global = {
          frame_color = "#8CAAEE";
          font = "Droid Sans 9";
          frame_width = 2;
          show_indicators = true;
        };
        urgency_normal = {
          background = "#303446";
          foreground = "#C6D0F5";
        };

        urgency_low = {
          background = "#303446";
          foreground = "#C6D0F5";
        };

        urgency_critical = {
          background = "#303446";
          foreground = "#C6D0F5";
          frame_color = "#EF9F76";
        };
      };
    };

    picom = {
      enable = false;
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
