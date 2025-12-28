return {
  "tiny-inline-diagnostic.nvim",
  after = function()
    require("tiny-inline-diagnostic").setup {
      profile = "powerline",
    }
    vim.diagnostic.config { virtual_text = false } -- Disable Neovim's default virtual text diagnostics
  end,
}