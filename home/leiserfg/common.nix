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
  };

  home.packages = with pkgs; [
    # --- Development Tools ---
    numbat
    # myPkgs.wl_shimeji
    # myPkgs.friction-graphics
    # love
    nix-playground
    mupdf
    nix-search-cli
    mosh
    nmap
    pandoc
    pinentry-qt
    cava
    exfatprogs
    # matugen
    localsend
    kitty-img
    # myPkgs.typsite
    # v4l-utils
    # dive
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
    python313Packages.ipython
    pipenv
    uv
    cmake
    gnumake
    gcc
    rustup
    nodejs
    tree-sitter
    lua-language-server
    kdePackages.qtdeclarative
    typst
    devenv
    nix
    nixd
    nix-update
    nixfmt-rfc-style
    nixpkgs-review
    taplo
    stylua
    shfmt
    shellcheck
    ty
    pyrefly
    (unstablePkgs.ruff)
    # basedpyright
    # typescript-language-server
    # gdb
    # inferno
    flamegraph
    glsl_analyzer
    myPkgs.glslviewer
    # myPkgs.friction-graphics
    myPkgs.jpegli
    # love
    # myPkgs.wl_shimeji
    # easyeffects
    rink
    uiua
    # figlet
    # ventoy-bin
    # presenterm
    # material-maker
    # git-branchless

    # --- Editor
    (neovimPkgs.neovim)

    # --- Networking & Communication ---
    mosh
    websocat
    (unstablePkgs.telegram-desktop)
    sshuttle
    autossh
    openssh
    croc
    doggo

    # --- System Utilities ---
    dragon-drop
    util-linux
    exfatprogs
    smartmontools
    pciutils
    lm_sensors
    lsof
    file
    psmisc
    htop
    dmidecode
    dua
    picocom # run as:  sudo picocom /dev/ttyACM0
    powertop
    usbutils
    gparted
    gnome-disk-utility
    rsync
    moreutils
    cntr
    patool
    unrar
    zpaq
    p7zip
    d-spy
    clinfo
    nix-du
    # age
    # agebox
    # age-kegen-deterministic

    # --- Media & Graphics ---
    mupdf
    zathura
    imv
    # krita
    # calibre
    vtracer
    inkscape
    ffmpeg-full
    gpu-screen-recorder
    kitty-img
    cava
    material-symbols
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    qpwgraph
    # darktable

    # --- File Management ---
    pcmanfm
    xarchiver
    unzip
    yadm

    # --- Fonts ---
    (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSS15"; })
    nerd-fonts.symbols-only

    # --- Audio ---
    pulseaudio
    pavucontrol

    # --- Cloud & Infra ---
    terraform-ls
    # awscli2
    docker-compose
    # cachix

    # --- Git & VCS ---
    git
    gh
    git-standup
    delta
    git-lfs
    # git-absorb

    # --- Search & Grep ---
    ripgrep
    ast-grep

    # --- Miscellaneous ---
    nix-playground
    tinymist
    shikane
    steam-run
    quickshell
    glib
    jq
    xh
    handlr-regex
    # --- Scripts & Custom Binaries ---
    (writeShellScriptBin "xdg-open" ''
      exec -a $0 ${handlr-regex}/bin/handlr open "$@"
    '')
    (writeShellScriptBin "vicinae-pp" ''
      printf " Performance\n Balanced\n Power Saver" \
      | vicinae dmenu \
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
      |vicinae dmenu \
      |xargs  -d '\n'  -I__  bash -c 'cd $HOME/Games/__/  && source *start*.sh'"
    '')
    (writeShellScriptBin "rofi_power" ''
      enumerate () {
          awk -F"|"  '{ for (i = 1; i <= NF; ++i) print "<big>"$i"</big><sub><small>"i"</small></sub>"; exit } '
      }
      question=$(printf "||||"| enumerate|vicinae dmenu)

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

    prek
  ];

  programs = {
    aria2 = {
      enable = true;
      settings = { };
    };
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
              rev = "6db0c60";
              hash = "sha256-0W1nQ8MJ+BgPyKcn+oDzntX9BXplJEyl8UjsHWCHrE8=";
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

  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
    };
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMCMD = "kitty";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MOZ_USE_XINPUT2 = "1";

    # Fix telegram input
    # ALSOFT_DRIVERS = "pulse";

    # Disable qt decoration for telegram
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # Make cargo use git to pull from github
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";

    # FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";

    # Force wayland for electron
    NIXOS_OZONE_WL = 1;

    # Fixes some qt programs crashing while using gtks file-dialog
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Classic";
    size = 16;
    x11.enable = true; # This is used also by Xwayland
    gtk.enable = true;
  };

  services = {
    trayscale.enable = true;
    gpg-agent.enable = true;
    udiskie = {
      enable = true;
      automount = true;
    };

    mpris-proxy.enable = true;
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
  };

  manual.manpages.enable = false; # Doc framework is broken; so let's stop updating this

  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps =
    let
      editor = "nvim.desktop";
    in
    {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/tg" = "telegram.desktop";
        # "x-scheme-handler/msteams" = "teams-for-linux.desktop";
        # "inode/directory" = "thunar.desktop";
        "inode/directory" = "pcmanfm.desktop";
        "text/*" = editor;
        "application/x-subrip" = editor;
        "application/zip" = "xarchiver.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/epub+zip" = "org.pwmt.zathura.desktop.desktop";
        # "image/*" = "com.github.weclaw1.ImageRoll.desktop";
      };
    };

  # mpv %U
  #     ^https?://(www.)?youtube.com/watch\?v=.*$
  # xdg.configFile."mimeo/associations.txt".text = ''
  #   mpv --loop %U
  #     ^.*.gif$
  #   sunvox %f
  #     ^.*.sunvox$
  # '';

  xdg.configFile."wireplumber/wireplumber.conf.d/10-bluetooth.conf".text = ''
    wireplumber.settings = {
       bluetooth.autoswitch-to-headset-profile = false
    }
  '';

  xdg.configFile."handlr/handlr.toml".source = (pkgs.formats.toml { }).generate "handlr.toml" {
    enable_selector = true;
    selector = "vicinae dmenu";
    handlers = [
      {
        regexes = [ "^.*.gif$" ];
        exec = "mpv --loop %U";
        terminal = false;
      }
      {
        regexes = [ "^.*.sunvox$" ];
        exec = "sunvox %f";
        terminal = false;
      }
    ];
  };

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

  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    extensions = [
      (config.lib.vicinae.mkRayCastExtension {
        name = "gif-search";
        sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
        rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
      })
      # (config.lib.vicinae.mkExtension {
      #   name = "test-extension";
      #   src =
      #     pkgs.fetchFromGitHub {
      #       owner = "schromp";
      #       repo = "vicinae-extensions";
      #       rev = "f8be5c89393a336f773d679d22faf82d59631991";
      #       sha256 = "sha256-zk7WIJ19ITzRFnqGSMtX35SgPGq0Z+M+f7hJRbyQugw=";
      #     }
      #     + "/test-extension";
      # })
    ];
  };
}
