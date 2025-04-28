{
  unstablePkgs,
  lib,
  pkgs,
  myPkgs,
  neovimPkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../shared/nix.nix
    ./features/rofi.nix
    ./features/audio.nix
    ./features/fish.nix
    ./features/nu.nix
    ./features/cmds.nix
    ./features/mpv.nix
    ./features/git.nix
    ./features/kitty.nix
  ];

  # disable news, they don't work well with flakes and message is anoying
  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };

  home = {
    username = lib.mkDefault "leiserfg";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
    enableNixpkgsReleaseCheck = false;
  };

  nix = {
    enable = true;
    package = pkgs.nix;
    gc = {
      automatic = true;
    };
  };

  home.packages = with pkgs; [
    # (inputs.fabric.packages.${pkgs.system}.run-widget)
    # (pkgs.pinentry-rofi.overrideAttrs (old: {rofi = pkgs.rofi-wayland;}))
    pandoc

    pinentry-qt
    cava
    localsend
    kitty-img
    v4l-utils
    gdb
    htop
    smartmontools
    devenv
    (unstablePkgs.shikane)
    nix
    steam-run
    glsl_analyzer
    myPkgs.glslviewer
    # glslviewer
    # easyeffects
    util-linux
    nix-update
    # inferno
    flamegraph
    psmisc
    python312Packages.ipython
    uv
    cmake
    gnumake
    python312
    teip
    typst
    (unstablePkgs.tdesktop)

    # (unstablePkgs.ags)
    shfmt
    shellcheck
    fish
    (unstablePkgs.ruff)
    basedpyright
    typescript-language-server
    pulseaudio

    pulseaudio
    nixd
    # pmenu
    pciutils
    # image-roll
    imv
    swayimg
    unzip

    dmidecode
    wf-recorder
    # iredis
    dua
    picocom # run as:  sudo picocom /dev/ttyACM0
    croc
    doggo
    # (neovimPkgs.neovim)
    neovim

    # figlet

    pipenv
    nixfmt-rfc-style
    nixpkgs-review
    jj
    bc
    ffmpeg-full
    jq
    graphviz
    gcc
    usbutils
    wget
    blueman
    pcmanfm
    xarchiver
    # gdb
    ventoy-bin
    rink
    uiua
    krita
    inkscape

    tree-sitter
    nodejs

    nmap
    glib
    (unstablePkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSS15"; })
    # (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    nerd-fonts.symbols-only

    (writeShellScriptBin "xdg-open" ''
      # export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s/:/\n/g"|grep -v "libXcursor"|xargs|sed "s/ /:/g")
      exec -a $0 ${mimeo}/bin/mimeo "$@"
    '')
    noto-fonts-emoji
    noto-fonts-cjk-sans
    vulkan-tools
    lm_sensors
    darktable
    gimp

    lua-language-server
    lsof
    file
    unrar
    zpaq
    p7zip
    d-spy
    gparted
    presenterm
    cntr
    pre-commit
    # age
    # agebox
    # age-kegen-deterministic

    # terraform
    terraform-ls
    awscli2

    pavucontrol
    zathura
    xdragon
    moreutils
    lf
    ripgrep
    ast-grep
    rustup
    simple-http-server

    gnome-disk-utility
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
    taplo
    yadm
    cachix
    android-tools
    git-lfs
    clinfo
    powertop
    docker-compose

    xh

    # My overlay
    # git-branchless
    # material-maker
    nix-du
    qpwgraph
    piper-tts

    libva-utils

    (makeDesktopItem {
      name = "teams-for-linux-call";
      exec = "teams-for-linux %U";
      icon = "teams-for-linux";
      desktopName = "Microsoft Teams for Linux";
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];
      mimeTypes = [ "x-scheme-handler/msteams" ];
    })

    #scripts
    # here we don't use the nix binaries to allow rewriting ruff with the correct one
    # see x11 and wayland

    (writeShellScriptBin "rofi-launch" ''
      exec -a $0 rofi -combi-modi window,drun,ssh -show combi -modi combi -show-icons
    '')

    (writeShellScriptBin "rofi-pp" ''
      printf " Performance\n Balanced\n Power Saver" \
      | rofi -dmenu -i \
      | tr -cd '[:print:]' \
      | xargs|tr " " "-" \
      | tr '[:upper:]' '[:lower:]' \
      | xargs powerprofilesctl set
    '')
    (writeShellScriptBin "pp-state" ''
      state=$(powerprofilesctl get | sed -e "s/.*string//" -e "s/.*save.*/ /"  -e "s/.*perf.*/ /"  -e "s/.*balanced.*/ /")
      echo $state
    '')
    (writeShellScriptBin "game-picker" ''
      exec  sh -c "ls ~/Games/*/*start*.sh  --quoting-style=escape \
      |xargs -n 1 -d '\n' dirname \
      |xargs -d '\n' -n 1 basename \
      |rofi -dmenu -i  \
      |xargs  -d '\n'  -I__  bash -c 'cd $HOME/Games/__/  && source *start*.sh'"
    '')
    (writeShellScriptBin "rofi_power" ''
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
    '')
  ];
  xdg.configFile."Thunar/uca.xml" = {
    executable = false;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
          <action>
              <icon>kitty</icon>
              <name>Open In Kitty</name>
              <submenu></submenu>
              <unique-id>1713512577329704-1</unique-id>
              <command>kitty -1 --directory %f</command>
              <description></description>
              <range>*</range>
              <patterns>*</patterns>
              <directories/>
          </action>
      </actions>
    '';
  };

  programs = {
    home-manager.enable = true;
    aria2.enable = true;
    bash = {
      enable = true;
      bashrcExtra = ''

        if [[ $(ps --no-header --pid=$PPID --format=comm|head -1) != "fish" && -z $BASH_EXECUTION_STRING && $SHLVL == 1 ]]
        then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec fish $LOGIN_OPTION
        fi
      '';
    };
    fzf = {
      enable = true;
      package = unstablePkgs.fzf;
      defaultOptions = [ "--color=light" ];
    };
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    firefox = {
      enable = true;
      # package = pkgs.firefox.override {
      #   nativeMessagingHosts = [
      #     pkgs.tridactyl-native
      #   ];
      # };
      # package = pkgs.firefox-devedition;
      profiles = {
        yolo = {
          userContent = "";
          userChrome = ''
            #TabsToolbar {
              visibility: collapse;
            }
            #sidebar-box #sidebar-header {
                display: none !important;
            }
          '';

          settings = {
            # Enable user chrome
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "sidebar.position_start" = false; # Sideberry in the right side

            "browser.compactmode.show" = true;
            "dom.webgpu.enabled" = true;
            "browser.uidensity" = 1;
            "media.ffmpeg.vaapi.enabled" = true;
            "media.ffvpx.enabled" = true;
            "browser.tabs.cardPreview.enabled" = true;
          };
          search.force = true;
          search.engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "NixOS Wiki" = {
              urls = [ { template = "https://wiki.nixos.org/index.php?search={searchTerms}"; } ];
              icon = "https://wiki.nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };

            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
      };
    };

    yt-dlp = {
      enable = true;
      settings = {
        cookies-from-browser = "firefox";
        downloader = "aria2c";
        downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      };
    };

    bat = {
      enable = true;
      # config.theme = "base16";
    };
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    yazi = {
      enable = true;
      shellWrapperName = "y";
      package = unstablePkgs.yazi;

      keymap = {
        input.prepend_keymap = [
          {
            run = "close";
            on = [ "<C-q>" ];
          }
          {
            run = "close --submit";
            on = [ "<Enter>" ];
          }
          {
            run = "escape";
            on = [ "<Esc>" ];
          }
          {
            run = "backspace";
            on = [ "<Backspace>" ];
          }
        ];
        manager.prepend_keymap = [
          {
            on = [ "<C-n>" ];
            run = ''shell 'dragon -x -i -T "$1"' --confirm'';
          }
          {
            on = "y";
            run = [
              ''shell 'echo "$@" |  wl-copy --type text/uri-list' --confirm''
              "yank"
            ];
          }

          {
            on = [
              "g"
              "r"
            ];
            run = ''shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm'';
          }
          {
            run = "escape";
            on = [ "<Esc>" ];
          }
          {
            run = "quit";
            on = [ "q" ];
          }
          {
            run = "close";
            on = [ "<C-q>" ];
          }
        ];
      };
    };
    rbw = {
      enable = true;
      settings = rec {
        # A bit of obfuscation doesn't hurt
        base_url = "https:" + "//bw.nul.mywire.org/";
        email = "${config.home.username}@gmail.com";
        lock_timeout = 60 * 60 * 8;
        pinentry = pkgs.pinentry-qt;
      };
    };
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
  qt.platformTheme.name = "gtk3";

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMCMD = "kitty";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MOZ_USE_XINPUT2 = "1";

    # Fix telegram input
    ALSOFT_DRIVERS = "pulse";

    # Disable qt decoration for telegram
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # Make cargo use git to pull from github
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";

    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    # Force wayland for electron
    NIXOS_OZONE_WL = 1;
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 16;
    x11.enable = true; # This is used also by Xwayland
    gtk.enable = true;
  };

  services = {
    darkman.enable = false;
    trayscale.enable = true;
    gpg-agent.enable = true;
    # pasystray.enable = true;

    udiskie = {
      enable = true;
      automount = true;
    };
    mpris-proxy.enable = true;
    dunst = {
      enable = false;
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
      # "x-scheme-handler/msteams" = "teams-for-linux.desktop";
      # "inode/directory" = "thunar.desktop";
      "inode/directory" = "pcmanfm.desktop";
      "text/x-python" = "neovim.desktop";
      "text/plain" = "neovim.desktop";
      "application/zip" = "xarchiver.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/epub+zip" = "org.pwmt.zathura.desktop.desktop";
      # "image/*" = "com.github.weclaw1.ImageRoll.desktop";
    };
  };

  # mpv %U
  #     ^https?://(www.)?youtube.com/watch\?v=.*$
  xdg.configFile."mimeo/associations.txt".text = ''
    mpv --loop %U
      ^.*.gif$
    sunvox %f
      ^.*.sunvox$
  '';

  # xdg.configFile."wireplumber/wireplumber.conf.d/10-disable-camera.conf".text = ''
  #   wireplumber.profiles = {
  #     main = {
  #       monitor.libcamera = disabled
  #     }
  #   }
  # '';

  xdg.configFile."wireplumber/wireplumber.conf.d/10-bluetooth.conf".text = ''
    wireplumber.settings = {
       bluetooth.autoswitch-to-headset-profile = false
    }
  '';

  # home.file.".local/state/wireplumber/sm-settings".text = lib.generators.toINI {} {
  #   sm-settings = {"bluetooth.autoswitch-to-headset-profile" = "true";};
  # };

  xdg.configFile."yt-dlp/config".text = ''
    --cookies-from-browser firefox
    --downloader aria2c
    --downloader-args aria2c:'-c -x8 -s8 -k1M'
    # Disable tv extractor to avoid DRM
    --extractor-args "youtube:player-client=default,-tv,web_safari,web_embedded"
  '';
}
