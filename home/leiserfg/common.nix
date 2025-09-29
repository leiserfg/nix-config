{
  lib,
  pkgs,
  myPkgs,
  neovimPkgs,
  unstablePkgs,
  config,
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
    ./features/aider.nix
  ];

  # disable news; they don't work well with flakes and message is anoying
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
    # gc = {
    #   automatic = true;
    # };
  };

  home.packages =
    with pkgs;
    [
      # myPkgs.wl_shimeji
      myPkgs.friction-graphics
      # love
      # (pkgs.pinentry-rofi.overrideAttrs (old: {rofi = pkgs.rofi-wayland;}))
      nix-playground
      mupdf
      nix-search-cli
      mosh
      nmap
      pandoc
      pinentry-qt
      cava
      exfatprogs
      matugen
      localsend
      kitty-img
      # v4l-utils
      dive
      # gdb
      htop
      smartmontools
      devenv
      shikane
      nix
      # (steam.override { extraLibraries = pkgs: [ pkgs.curlWithGnuTls ]; }).run
      steam-run
      quickshell
      myPkgs.jpegli
      glsl_analyzer
      myPkgs.glslviewer
      # glslviewer
      # easyeffects
      util-linux
      nix-update
      # inferno
      flamegraph
      psmisc
      python313Packages.ipython
      python3
      uv
      cmake
      gnumake
      teip
      typst

      tinymist
      websocat
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

      imv
      eog
      unzip

      dmidecode
      wf-recorder
      gpu-screen-recorder
      # iredis
      dua
      picocom # run as:  sudo picocom /dev/ttyACM0
      croc
      doggo
      (neovimPkgs.neovim)
      # neovim

      # figlet

      pipenv
      nixfmt-rfc-style
      nixpkgs-review
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
      # ventoy-bin
      rink
      uiua
      krita
      inkscape

      tree-sitter
      nodejs

      nmap
      glib
      (unstablePkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSS15"; })
      nerd-fonts.symbols-only
      material-symbols

      (writeShellScriptBin "xdg-open" ''
        exec -a $0 ${mimeo}/bin/mimeo "$@"
      '')
      noto-fonts-emoji
      noto-fonts-cjk-sans
      vulkan-tools
      lm_sensors
      # darktable
      # dnglab

      lua-language-server
      kdePackages.qtdeclarative

      lsof
      file
      unrar
      zpaq
      p7zip
      d-spy
      gparted
      # presenterm
      cntr
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
      # git-absorb

      patool
      stylua
      # taplo
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
      libva-utils

      # (makeDesktopItem {
      #   name = "teams-for-linux-call";
      #   exec = "teams-for-linux %U";
      #   icon = "teams-for-linux";
      #   desktopName = "Microsoft Teams for Linux";
      #   categories = [
      #     "Network"
      #     "InstantMessaging"
      #     "Chat"
      #   ];
      #   mimeTypes = [ "x-scheme-handler/msteams" ];
      # })

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
    ]
    ++ (if builtins.hasAttr "prek" pkgs then [ pkgs.prek ] else [ pkgs.pre-commit ]);

  # xdg.configFile."Thunar/uca.xml" = {
  #   executable = false;
  #   text = ''
  #     <?xml version="1.0" encoding="UTF-8"?>
  #     <actions>
  #         <action>
  #             <icon>kitty</icon>
  #             <name>Open In Kitty</name>
  #             <submenu></submenu>
  #             <unique-id>1713512577329704-1</unique-id>
  #             <command>kitty -1 --directory %f</command>
  #             <description></description>
  #             <range>*</range>
  #             <patterns>*</patterns>
  #             <directories/>
  #         </action>
  #     </actions>
  #   '';
  # };

  programs = {
    home-manager.enable = true;

    aria2.enable = true;
    bash = {
      enable = true;
      initExtra = ''
        if [[ $SHLVL == 1 ]]
        then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec nu $LOGIN_OPTION
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
            "widget.wayland.fractional-scale.enabled" = true;
            "browser.compactmode.show" = true;
            "dom.webgpu.enabled" = true;
            "browser.uidensity" = 1;
            "media.ffmpeg.vaapi.enabled" = true;
            "media.ffvpx.enabled" = true;
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
      package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };
      shellWrapperName = "y";
      initLua = ''
        require("gvfs"):setup()
      '';

      plugins = {
        inherit (pkgs.yaziPlugins) smart-filter;
        gvfs = (
          pkgs.stdenvNoCC.mkDerivation rec {
            pname = "gvfs.yazi";
            version = "0.0.1";

            src = pkgs.fetchFromGitHub {
              owner = "boydaihungst";
              repo = pname;
              rev = "8303bed80f10464e64a1d26d09c78bd61f7d6d47";
              hash = "sha256-v+aCRh3cukA8ahv+Hh+FAcbWMnIJHOUYnRax7XQTXVM=";
            };

            buildPhase = ''
              mkdir $out
              cp -r $src/* $out
            '';
          }
        );
      };
      settings = {

        plugin = {
          prepend_preloaders = [
            {
              name = "/run/user/1000/gvfs/**/*";
              run = "noop";
            }
          ];
          prepend_previewers = [
            # Allow to preview folder.
            {
              name = "*/";
              run = "folder";
            }

            # Do not previewing files in mounted locations (uncomment this line to except text file):
            {
              mime = "{text/*,application/x-subrip}";
              run = "code";
            }

            # Using absolute path.
            {
              name = "/run/user/1000/gvfs/**/*";
              run = "noop";
            }
          ];
        };
      };
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

        mgr.prepend_keymap = [
          {
            on = [ "F" ];
            run = ''plugin smart-filter'';
            desc = "Smart filter";
          }
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
          {
            on = [
              "M"
              "m"
            ];
            run = "plugin gvfs -- select-then-mount";
            desc = "Select device then mount";
          }
          {
            on = [
              "M"
              "u"
            ];
            run = "plugin gvfs -- select-then-unmount --eject";
            desc = "Select device then eject";
          }
          {
            on = [
              "M"
              "a"
            ];
            run = "plugin gvfs -- add-mount";
            desc = "Add a GVFS mount URI";
          }
          {
            on = [
              "g"
              "m"
            ];
            run = "plugin gvfs -- jump-to-device";
            desc = "Select device then jump to its mount point";
          }

          {
            on = [
              "M"
              "e"
            ];
            run = "plugin gvfs -- edit-mount";
            desc = "Edit a GVFS mount URI";
          }

          # Remove a Scheme/Mount URI
          {
            on = [
              "M"
              "r"
            ];
            run = "plugin gvfs -- remove-mount";
            desc = "Remove a GVFS mount URI";
          }
        ];
      };
    };

    rbw = {
      enable = true;
      settings = {
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
    # darkman.enable = false;
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

  manual.manpages.enable = false; # Doc framework is broken; so let's stop updating this
  # xdg.enable = true ;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/tg" = "telegram.desktop";
      "x-scheme-handler/msteams" = "teams-for-linux.desktop";
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

  xdg.configFile."wireplumber/wireplumber.conf.d/10-bluetooth.conf".text = ''
    wireplumber.settings = {
       bluetooth.autoswitch-to-headset-profile = false
    }
  '';

  home.file."${config.xdg.configHome}/nvim/spell/de.utf-8.spl".source = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl";
    sha256 = "sha256:1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
  };
  home.file.".local/share/file-manager/actions/action.desktop".text = ''
    [Desktop Entry]
    Type=Action
    Profiles=profile_id
    Name=Send to telegram
    Icon=telegram

    [X-Action-Profile profile_id]
    MimeTypes=all/all;
    Exec=Telegram -sendpath %F
  '';
}
