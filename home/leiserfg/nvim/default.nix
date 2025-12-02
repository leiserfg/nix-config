{
  config,
  lib,
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
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      enable = true;
      # nixpkgs_version = inputs.nixpkgs;
      # this will add the overlays from ./overlays and also,
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      addOverlays = # (import ./overlays inputs) ++
        [
          (utils.standardPluginOverlay inputs)
        ];
      # see the packageDefinitions below.
      # This says which of those to install.
      packageNames = [ "myHomeModuleNvim" ];

      luaPath = ./.;

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
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
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps.general = with pkgs; [
            lua-language-server
            stylua
            nixd
            ty
            rust-analyzer

            # typist-preview
            tinymist
            websocat

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
          ];

          # This is for plugins that will load at startup without using packadd:
          startupPlugins.general = with pkgs.vimPlugins; [
            # lazy loading isnt required with a config this small
            # but as a demo, we do it anyway.
            lze
            lzextras
            snacks-nvim
            typst-preview-nvim
            # onedark-nvim
            # vim-sleuth
          ];

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          optionalPlugins.general =
            with pkgs.vimPlugins;
            [
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
              gitlinker-nvim
              codecompanion-nvim
              gx-nvim
            ]
            ++ (with pkgs.neovimPlugins; [ wildfire ]);

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries.general = with pkgs; [ ];

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            # test = {
            #   CATTESTVAR = "It worked!";
            # };
          };

          # categories of the function you would have passed to withPackages
          python3.libraries = {
            # test = [ (_:[]) ];
          };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = {
            # test = [
            #   '' --set CATTESTVAR2 "It worked again!"''
            # ];
          };
        }
      );

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        myHomeModuleNvim =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              # unwrappedCfgPath = "/path/to/here"

              aliases = [
                "vim"
                "homeVim"
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
