{
  pkgs,
  myPkgs,
  inputs,
  unstablePkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # --- AI & LLM ---
    llama-cpp-vulkan

    # --- Development Tools ---
    gcc
    gdb
    cmake
    gnumake
    rustup
    nodejs
    pnpm
    tree-sitter
    lua-language-server
    typescript
    kdePackages.qtdeclarative
    python3
    python313Packages.ipython
    pipenv
    uv
    devenv
    nix
    nixd
    nix-update
    nixfmt
    nixpkgs-review
    nix-playground
    nix-search-cli
    stylua
    ty
    (unstablePkgs.ruff)
    terraform-ls
    awscli2
    awslogs
    docker-compose
    act
    glsl_analyzer
    glslviewer

    # --- Git & VCS ---
    git
    gh
    git-standup
    delta
    git-lfs
    prek

    # --- Search & Grep ---
    ripgrep
    ast-grep

    # --- Networking & Communication ---
    mosh
    websocat
    (unstablePkgs.telegram-desktop)
    sshuttle
    autossh
    openssh
    croc
    doggo
    nmap

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
    tio
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
    nix-tree
    flamegraph
    inferno

    # --- Media & Graphics ---
    mupdf
    zathura
    imv
    krita
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
    scrcpy
    guvcview

    # --- File Management ---
    pcmanfm
    xarchiver
    unzip
    yadm

    # --- Fonts ---
    (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSS15"; })
    nerd-fonts.symbols-only

    # --- Audio ---
    pwvucontrol

    # --- Documents ---
    pandoc
    pinentry-qt
    typst
    tinymist

    # --- Misc ---
    brightnessctl
    love
    ntfs3g
    localsend
    wtype
    voxtype-vulkan
    quickshell
    steam-run
    glib
    jq
    xh
    handlr-regex
    rink
    uiua
    shikane
  ];
}
