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
    enableNixpkgsReleaseCheck = false;
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
    easyeffects
    autorandr
    util-linux
    podman
    nix-update
    cni-plugins
    /*
    sioyek
    */
    gnumake
    (unstablePkgs.tdesktop)
    (unstablePkgs.fish)
    (unstablePkgs.ruff)
    (unstablePkgs.nodePackages.pyright)
    nil
    pmenu
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
    dua
    picocom
    /*
    luajit
    */
    doggo
    neovim-unwrapped
    sumneko-lua-language-server
    pipenv
    sqlitebrowser
    alejandra
    nix-prefetch-git
    appimage-run
    # clangd
    /*
    clang-tools
    */
    # llvmPackages.clang
    bc
    zk
    ffmpeg_5-full
    jq
    graphviz
    gcc
    usbutils
    wget
    nodePackages.npm
    light
    blueman
    pcmanfm
    xarchiver
    calibre
    # krita
    pinentry.qt
    (unstablePkgs.iosevka-bin.override {variant = "sgr-iosevka-term-ss07";})
    (unstablePkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    # This is a HACK to make telegram from unstable work with firefox from stable
    (writeShellScriptBin "xdg-open" ''
      export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s/:/\n/g"|grep -v "libXcursor"|xargs|sed "s/ /:/g")
      exec -a $0 ${mimeo}/bin/mimeo $@
    '')
    noto-fonts-emoji
    /*
    twemoji-color-font
    */
    noto-fonts-cjk-sans
    noto-fonts

    lm_sensors
    darktable
    gimp
    (unstablePkgs.kitty)
    # rofi
    picom
    /*
    awesome
    */
    xorg.xkill
    # unstablePkgs.qtile
    polkit_gnome

    lua-language-server
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
    xorg.xrandr
    xcwd
    moreutils
    htop
    lf
    fzf
    ripgrep
    rustup
    simple-http-server
    /*
    rust-analyzer-unwrapped
    */
    gnome.gnome-disk-utility
    mupdf
    rsync
    # appimage-run

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
    git-lfs
    clinfo

    docker-compose
    xorg.xev

    # My overlay
    git-branchless
    # wasm2luajit
    # godot4
    # glslviewer
    # armourpaint
    # nsxiv-extras
    # material-maker
    nix-du
    yt-dlp
    helvum
  ];

  programs = {
    home-manager.enable = true;

    fzf.enable = true;
    lf.enable = true;
    mpv = {
      enable = true;
      scripts = [pkgs.mpvScripts.mpris pkgs.mpvScripts.sponsorblock];
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
  };

  qt.enable = true;
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMCMD = "kitty";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MOZ_USE_XINPUT2 = "1";

    # Fix telegram input
    ALSOFT_DRIVERS = "pulse";
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
    # windowManager.command = "awesome";
    windowManager.command = "qtile start";
  };

  services = {
    xsettingsd = {
      enable = false;
      settings = {
        "Xft/DPI" = 98304;
        "Xft/Antialias" = true;
        "Xft/HintStyle" = "hintfull";
        "Xft/Hinting" = true;
        "Xft/RGBA" = "none";
      };
    };

    gpg-agent.enable = true;
    unclutter.enable = false;
    cbatticon = {
      enable = false;
      lowLevelPercent = 50;
      criticalLevelPercent = 30;
    };
    caffeine.enable = true;
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
      enable = true;
      vSync = true;
      backend = "xr_glx_hybrid";
      settings = {
        # xrender-sync-fence = true;
      };
    };

    blueman-applet.enable = true;
    network-manager-applet.enable = true;

    pasystray.enable = false;
    flameshot.enable = true;
    /*
    screen-locker = with pkgs; {
    */
    /*
    enable = true;
    */
    /*
    lockCmd = "${i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 5 pixel";
    */
    /*
    };
    */
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
      "text/x-python" = "neovim.desktop";
      "application/zip" = "xarchiver.desktop";
    };
  };
}
