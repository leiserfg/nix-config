{ neovimPkgs, inputs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];
  programs.nvf = {
    enable = true;
    settings = {
      vim.package = neovimPkgs.neovim;
      vim.viAlias = true;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };
}
