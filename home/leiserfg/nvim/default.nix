{
  pkgs,
  myPkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

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
      pyrefly
      yamlfix
      myPkgs.pytest-language-server
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
      (nvim-test.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "klen";
          repo = "nvim-test";
          rev = "feb834cbc806029239479f501e8492c01a2bea65";
          hash = "sha256-DTns8LG3PFFKYG6Ayt90Brf2lbZjNfDLLKUDxsqMisk=";
        };
        dependencies = with self; [
          nvim-treesitter
          nvim-treesitter-parsers.c_sharp
          nvim-treesitter-parsers.go
          nvim-treesitter-parsers.haskell
          nvim-treesitter-parsers.javascript
          nvim-treesitter-parsers.python
          nvim-treesitter-parsers.ruby
          nvim-treesitter-parsers.rust
          nvim-treesitter-parsers.typescript
          nvim-treesitter-parsers.zig
        ];
      }))
      vim-test
      rustaceanvim
      vim-suda
      yazi-nvim
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          bash
          c
          css
          cpp
          csv
          elixir
          gitcommit
          query
          html
          hurl
          json
          lua
          markdown
          markdown_inline
          nix
          nu
          python
          regex
          rust
          sql
          toml
          typescript
          terraform
          typst
          yaml
          vimdoc
        ]
      ))
      lualine-nvim
      lualine-lsp-progress
      render-markdown-nvim
      friendly-snippets
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
