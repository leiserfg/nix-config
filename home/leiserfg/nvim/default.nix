{
  inputs,
  ...
}:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [
    inputs.nixCats.homeModule
  ];
  config = {
    nixCats = {
      enable = true;
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      addOverlays = # (import ./overlays inputs) ++
        [
          (utils.standardPluginOverlay inputs)
        ];
      packageNames = [ "nvim" ];

      luaPath = ./.;

      categoryDefinitions.replace = (
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          lspsAndRuntimeDeps.general = with pkgs; [
            lua-language-server
            stylua
            nixd
            ty
            rust-analyzer

            # typist-preview
            tinymist
            websocat
            # markdown
            mpls

            typescript
            uiua
            glsl_analyzer
            ruff
            shfmt
            shellcheck
            nixfmt-rfc-style
            lua-language-server
            typescript
            nixd
            terraform-ls
            taplo
            pyrefly
          ];

          startupPlugins.general = with pkgs.vimPlugins; [
            lze
            lzextras
            typst-preview-nvim
            deepwhite-nvim
            nvim-parinfer
          ];

          optionalPlugins.general =
            with pkgs.vimPlugins;
            [
              tiny-inline-diagnostic-nvim
              vim-startuptime
              mini-nvim
              nvim-lspconfig
              blink-cmp
              typescript-tools-nvim
              luasnip
              quicker-nvim
              rustaceanvim
              vim-suda
              yazi-nvim
              # nvim-treesitter.withPlugins.withAllGrammars
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
              codecompanion-nvim
              fzf-lua
              gx-nvim
            ]
            ++ (with pkgs.neovimPlugins; [ wildfire ]);

          # shared libraries to be added to LD_LIBRARY_PATH
          sharedLibraries.general = with pkgs; [ ];

          environmentVariables = {
            # test = {
            #   CATTESTVAR = "It worked!";
            # };
          };
        }
      );

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        nvim =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = "NO_WRAP";
              # unwrappedCfgPath = "/path/to/here"

              aliases = [
                "vim"
                "vi"
              ];
              neovim-unwrapped = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
              hosts.python3.enable = false;
              hosts.perl.enable = false;
              hosts.node.enable = false;
              hosts.ruby.enable = false;
            };
            categories = {
              general = true;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
            };
          };
      };
    };
  };
}
