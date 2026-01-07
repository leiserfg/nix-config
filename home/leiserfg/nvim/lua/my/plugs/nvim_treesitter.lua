return {
  "nvim-treesitter",
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd "wildfire"
  end,
  after = function(plugin)
    vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "<filetype>" },
      callback = function()
        vim.treesitter.start()
      end,
    })
    require("wildfire").setup {
      -- keymaps = {
      --   init_selection = "<c-space>",
      --   node_incremental = "<c-space>",
      --   scope_incremental = "<nop>",
      --   node_decremental = "<bs>",
      -- },
    }
  end,
}

