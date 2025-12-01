{ neovimPkgs, inputs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];
  programs.nvf = {
    enable = false;
    settings.vim = {
      package = neovimPkgs.neovim;
      viAlias = true;
      vimAlias = true;
      lsp = {
        enable = true;
      };
      languages = {
        python.enable = true;
        rust.enable = true;
        nix.enable = true;
        typst.enable = true;
        lua.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
        };
      };

      snippets.luasnip.enable = true;
      git = {
        enable = true;
        gitsigns.enable = true;
      };
      autocomplete.blink-cmp.enable = true;

      # assistant.codecompanion-nvim.enable = true;
    };
  };
}
