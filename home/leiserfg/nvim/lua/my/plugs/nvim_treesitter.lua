vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "<filetype>" },
  callback = function()
    vim.treesitter.start()
  end,
})

