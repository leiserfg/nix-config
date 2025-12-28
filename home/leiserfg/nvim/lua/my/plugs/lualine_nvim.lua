return {
  "lualine.nvim",
  event = "DeferredUIEnter",
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd "lualine-lsp-progress"
  end,
  after = function(plugin)
    require("lualine").setup {
      extensions = { "quickfix", "man" },
      options = {
        component_separators = "",
        section_separators = "",
        globalstatus = true,
        icons_enabled = false,
      },
      sections = {
        lualine_b = {
          {
            require "my/lualine_rec",
            "lsp_progress",
          },
        },
      },
    }
  end,
}

