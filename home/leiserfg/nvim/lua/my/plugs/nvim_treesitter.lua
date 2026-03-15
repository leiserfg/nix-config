return {
  "nvim-treesitter",
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
  end,
  after = function(plugin)
    vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "<filetype>" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}

