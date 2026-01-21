require "my.options"
require "my.keymap"

vim.cmd.colorscheme "notebook"

local map = vim.keymap.set
local opts = { silent = true, expr = true }

map("i", "<c-j>", function()
  return require("luasnip").expand_or_jumpable() and "<Plug>luasnip-expand-or-jump" or "<c-j>"
end, opts)
map("i", "<c-k>", function()
  return require("luasnip").jumpable(-1) and "<Plug>luasnip-jump-prev" or "<c-k>"
end, opts)

map("i", "<c-e>", function()
  return require("luasnip").choice_active() and "<Plug>luasnip-next-choice" or "<c-e>"
end, opts)

map("s", "<c-j>", function()
  require("luasnip").jump(1)
end, { silent = true })
map("s", "<c-k>", function()
  require("luasnip").jump(-1)
end, { silent = true })
map("v", "<c-f>", function()
  require("luasnip.extras.otf").on_the_fly()
end, { silent = true })
map("i", "<c-f>", function()
  require("luasnip.extras.otf").on_the_fly "e"
end, { silent = true })

require("lze").load {
  require "my.plugs.luasnip",
  {
    "friendly-snippets",
    dep_of = "luasnip",
  },
  {
    "tiny-inline-diagnostic.nvim",
    after = function()
      require("tiny-inline-diagnostic").setup {
        profile = "powerline",
      }
      vim.diagnostic.config { virtual_text = false } -- Disable Neovim's default virtual text diagnostics
    end,
  },

  require "my.plugs.blink_cmp",
  require "my.plugs.nvim_treesitter",
  require "my.plugs.yazi_nvim",
  {
    "vim-suda",
    after = function()
      vim.g.suda_smart_edit = 1
    end,
  },
  {
    "quicker.nvim",
    ft = "qf",
    after = function()
      require("quicker").setup()
    end,
  },
  require "my.plugs.mini_nvim",
  require "my.plugs.vim_startuptime",
  require "my.plugs.lualine_nvim",
  require "my.plugs.gitsigns_nvim",
  require "my.plugs.nvim_lint",
  {
    "typst-preview.nvim",
    ft = { "typst" },
    after = function()
      require("typst-preview").setup {
        dependencies_bin = { ["tinymist"] = "tinymist", ["websocat"] = "websocat" },
      }
    end,
  },

  { "plenary.nvim", on_require = "plenary" },
  {
    "render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    after = function()
      require("render-markdown").setup()
    end,
  },
  require "my.plugs.dial_nvim",
  require "my.plugs.gx_nvim",
  { "copilot.lua", cmd = "Copilot" }, -- only for doing :Copilot auth
  require "my.plugs.codecompanion_nvim",
  require "my.plugs.conform_nvim",
  require "my.plugs.fzf-lua",
  {
    "gitlinker.nvim",
    after = function()
      require("gitlinker").setup()
    end,
    event = "DeferredUIEnter",
  },
}
require "my.lsp"
