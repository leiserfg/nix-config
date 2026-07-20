{
  pkgs,
  myPkgs,
  # neovimPkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # package = neovimPkgs.default;

    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
    withPerl = false;

    extraPackages = with pkgs; [
      lua-language-server
      stylua
      nixd
      ty
      rust-analyzer
      tinymist
      websocat
      mpls
      typescript
      uiua
      glsl_analyzer
      ruff
      shfmt
      shellcheck
      nixfmt
      terraform-ls
      taplo
      # pyrefly
      # zuban
      yamlfix
      myPkgs.pytest-language-server
      # nimlangserver
      nimlsp
    ];

    plugins = with pkgs.vimPlugins; [
      typst-preview-nvim
      nvim-parinfer
      tiny-inline-diagnostic-nvim
      vim-startuptime
      mini-nvim
      blink-cmp
      typescript-tools-nvim
      luasnip
      quicker-nvim
      vim-dispatch
      rustaceanvim
      # vim-suda   in nixos I never need this
      yazi-nvim
      (nvim-treesitter.withPlugins (ts: [
        ts.bash
        ts.c
        ts.css
        ts.cpp
        ts.csv
        ts.elixir
        ts.gitcommit
        ts.query
        ts.html
        ts.hurl
        ts.json
        ts.lua
        ts.markdown
        ts.markdown_inline
        ts.nix
        ts.nu
        ts.nim
        ts.python
        ts.regex
        ts.rust
        ts.sql
        ts.toml
        ts.typescript
        ts.terraform
        ts.typst
        ts.yaml
        ts.vimdoc
      ]))
      lualine-nvim
      lualine-lsp-progress

      render-markdown-nvim
      # friendly-snippets
      gitsigns-nvim
      nvim-lint
      conform-nvim
      plenary-nvim
      dial-nvim
      fzf-lua
      gx-nvim
      gitlinker-nvim
    ];

    # Point to your init.lua configuration file
    initLua = # lua
      ''
        package.path = "${./lua}/?.lua;${./lua}/?/init.lua;" .. package.path
        require "my"
      '';

  };

  xdg.configFile = {
    "nvim/colors".source = ./colors;
    "nvim/plugin".source = ./plugin;
  };

  # Create aliases for vim and vi
  home.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };
}
