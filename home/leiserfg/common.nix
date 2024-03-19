{
  unstablePkgs,
  lib,
  pkgs,
  myPkgs,
  config,
  ...
}: {
  imports = [../../shared/nix.nix ./features/rofi.nix];

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
    unstablePkgs.steam-run
    easyeffects
    util-linux
    nix-update
    # inferno
    flamegraph
    python311Packages.ipython
    ollama
    (unstablePkgs.tdesktop)
    # firefox
    (unstablePkgs.fish)
    (unstablePkgs.ruff)
    (myPkgs.basedpyright)
    nil
    pmenu
    glxinfo
    pciutils
    imv
    unzip
    nodePackages.typescript-language-server

    iw
    dmidecode
    vokoscreen-ng
    zoxide
    # iredis
    dua
    picocom # run as:  sudo picocom /dev/ttyACM0

    doggo
    neovim-unwrapped
    sumneko-lua-language-server
    pipenv
    alejandra
    nix-prefetch-git
    bc
    ffmpeg_5-full
    jq
    graphviz
    gcc
    usbutils
    wget
    blueman
    pcmanfm
    xarchiver

    ventoy-bin
    rink
    unstablePkgs.uiua
    krita
    inkscape
    tree-sitter
    nmap
    # krita
    # pinentry.qt
    # unstablePkgs.cinnamon.warpinator
    (unstablePkgs.iosevka-bin.override {variant = "SGr-IosevkaTermSS07";})
    (unstablePkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    (writeShellScriptBin "xdg-open" ''
      # export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s/:/\n/g"|grep -v "libXcursor"|xargs|sed "s/ /:/g")
      exec -a $0 ${mimeo}/bin/mimeo "$@"
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
    (myPkgs.kitty)
    # foot
    /*
    awesome
    */
    xorg.xkill
    # unstablePkgs.qtile

    lua-language-server
    lsof
    file
    unrar
    aria2
    zpaq
    p7zip
    dfeet
    gparted

    pavucontrol
    zathura
    xdragon
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

    patool
    stylua
    yadm
    cachix
    android-tools
    git-lfs
    clinfo
    powertop
    docker-compose

    xh

    # My overlay
    git-branchless
    # material-maker
    nix-du
    qpwgraph
    piper-tts

    libva-utils
    #scripts
    # here we don't use the nix binaries to allow rewriting ruff with the correct one
    # see x11 and wayland

    (writeShellScriptBin "rofi-launch" ''
      exec -a $0 rofi -combi-modi window,drun,ssh -show combi -modi combi -show-icons
    '')

    (
      writeShellScriptBin "rofi-pp" ''
        printf " Performance\n Balanced\n Power Saver" \
        | rofi -dmenu -i \
        | tr -cd '[:print:]' \
        | xargs|tr " " "-" \
        | tr '[:upper:]' '[:lower:]' \
        | xargs powerprofilesctl set
      ''
    )
    (
      writeShellScriptBin "pp-state" ''
        state=$(powerprofilesctl get | sed -e "s/.*string//" -e "s/.*save.*/ /"  -e "s/.*perf.*/ /"  -e "s/.*balanced.*/ /")
        echo $state
      ''
    )
    (
      writeShellScriptBin "game-picker" ''
        exec  sh -c "ls ~/Games/*/*start*.sh  --quoting-style=escape \
        |xargs -n 1 -d '\n' dirname \
        |xargs -d '\n' -n 1 basename \
        |rofi -dmenu -i  \
        |xargs  -d '\n'  -I__  bash -c 'cd $HOME/Games/__/  && source *start*.sh'"
      ''
    )
    (
      writeShellScriptBin "rofi_power" ''
        enumerate () {
            awk -F"|"  '{ for (i = 1; i <= NF; ++i) print "<big>"$i"</big><sub><small>"i"</small></sub>"; exit } '
        }
        question=$(printf "||||"| enumerate|rofi -dmenu -markup-rows)

        case $question in
            **)
                loginctl lock-session $XDG_SESSION_ID
                ;;
            **)
                systemctl suspend
                ;;
            **)
                # bspc quit || qtile cmd-obj -o cmd -f shutdown
                systemctl --user  stop graphical-session.target
                hyprctl dispatch exit || loginctl terminate-session $XDG_SESSION_ID
                ;;
            **)
                systemctl reboot
                ;;
            **)
                systemctl poweroff
                ;;
            *)
                exit 0  # do nothing on wrong response
                ;;
        esac
      ''
    )
  ];

  programs = {
    home-manager.enable = true;
    bash = {
      enable = true;
      bashrcExtra = ''

        case $- in
            *i*) ;;
              *) return;;
        esac

        if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z $BASH_EXECUTION_STRING ]] && which fish > /dev/null
        then
            exec fish
        fi

      '';
    };
    fzf.enable = true;

    firefox = {
      enable = true;
      profiles = {
        yolo = {
          settings = {
            "browser.compactmode.show" = true;
            "dom.webgpu.enabled" = true;

            # VP9 fails to work with vaapi in framework so we have to disable it until this gets fixed
            # # Delete this after https://gitlab.freedesktop.org/mesa/mesa/-/issues/8044
            # This was a workaround but makes it vp9 only videos not to show in youtube
            # "media.mediasource.vp9.enabled" = false;
            #
            "media.ffmpeg.vaapi.enabled" = true;
            "media.ffvpx.enabled" = true;
          };
        };
      };
    };

    yt-dlp = {
      enable = true;
      settings = {
        cookies-from-browser = "firefox";
        downloader = "aria2c";
      };
    };
    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        uosc
        thumbfast
        mpris
        sponsorblock
      ];
      scriptOpts = {
        uosc = {
          top_bar = "always"; # This makes uosc work fine in wayland
        };
      };
    };

    bat = {
      enable = true;
      config.theme = "base16";
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
      package = pkgs.inter;
      name = "Inter";
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
    x11.enable = true; # This is used also by Xwayland
    gtk.enable = true;
  };

  services = {
    gpg-agent.enable = true;
    pasystray.enable = true;

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
          dmenu = "rofi -dmenu -p dunst";
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

    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };
  # Force Rewrite

  manual.manpages.enable = false; # Doc framework is broken, so let's stop updating this
  # xdg.enable = true ;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/tg" = "telegram.desktop";
      "inode/directory" = "pcmanfm.desktop";
      "text/x-python" = "neovim.desktop";
      "text/plain" = "neovim.desktop";
      "application/zip" = "xarchiver.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop.desktop";
      "image/*" = "imv.desktop";
    };
  };

  home.sessionVariables = {
    GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
  };

  # systemd.user.services.polkit-authentication-agent = {
  #   Unit = {
  #     Description = "Polkit authentication agent";
  #     Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
  #     After = ["graphical-session-pre.target"];
  #     PartOf = ["graphical-session.target"];
  #   };
  #
  #   Service = {
  #     ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
  #     Restart = "always";
  #     BusName = "org.freedesktop.PolicyKit1.Authority";
  #   };
  #
  #   Install.WantedBy = ["graphical-session.target"];
  # };
}
