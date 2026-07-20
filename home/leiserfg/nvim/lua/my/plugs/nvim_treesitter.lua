vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "*" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
