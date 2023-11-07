{
  unstablePkgs,
  lib,
  pkgs,
  config,
  ...
}: {
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
    unstablePkgs.steam-run
    easyeffects
    util-linux
    nix-update
    python311Packages.ipython
    (unstablePkgs.tdesktop)
    firefox
    (unstablePkgs.fish)
    (unstablePkgs.ruff)
    (unstablePkgs.nodePackages.pyright)
    nil
    pmenu
    glxinfo
    unzip
    nodePackages.typescript-language-server

    vokoscreen-ng
    zoxide
    iredis
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
    tree-sitter
    nmap
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
    zathura
    nsxiv
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
    git-bug

    patool
    stylua
    yadm
    cachix
    android-tools
    git-lfs
    clinfo

    docker-compose

    # My overlay
    git-branchless
    # material-maker
    nix-du
    yt-dlp
    helvum

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
        printf %s\n\n $state
      ''
    )
    (
      writeShellScriptBin "game-picker" ''
        exec  gamemoderun sh -c " ls ~/Games/*/*start.sh  --quoting-style=escape \
        |xargs -n 1 -d '\n' dirname \
        |xargs -d '\n' -n 1 basename \
        |rofi -dmenu -i  \
        |xargs  -d '\n'  -I__  bash -c  '$HOME/Games/__/*start.sh'"
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
    # bash.enable = true;
    fzf.enable = true;

    mpv = {
      enable = true;
      scripts = [
        pkgs.mpvScripts.mpris
        pkgs.mpvScripts.sponsorblock
      ];
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
    x11.enable = true; # This is used also by Xwayland
    gtk.enable = true;
  };

  services = {
    gpg-agent.enable = true;
    pasystray.enable = true;
    cbatticon = {
      enable = false;
      lowLevelPercent = 50;
      criticalLevelPercent = 30;
    };

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
    };
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
