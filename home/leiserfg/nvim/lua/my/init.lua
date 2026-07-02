collectgarbage "stop"

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

-- Setup plugins directly
require "my.plugs.blink_cmp"
require "my.plugs.nvim_treesitter"
require "my.plugs.lualine_nvim"
require "my.plugs.gitsigns_nvim"
require "my.lsp"

-- Simple plugin setups
vim.g.suda_smart_edit = 1

-- Defer plugin loading until after editor is fully loaded
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    require "my.plugs.luasnip"
    require "my.plugs.tiny_inline_diagnostic_nvim"
    require "my.plugs.yazi_nvim"
    require "my.plugs.mini_nvim"
    require "my.plugs.nvim_lint"
    require "my.plugs.dial_nvim"
    require "my.plugs.conform_nvim"
    require "my.plugs.fzf-lua"
    require("quicker").setup()
    require("gitlinker").setup()
    
    -- Disabled until fixed
    require("nvim-test").setup()

    require("typst-preview").setup {
      dependencies_bin = { ["tinymist"] = "tinymist", ["websocat"] = "websocat" },
    }

    require("render-markdown").setup()

    collectgarbage "restart"
  end,
})

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    collectgarbage "restart"
  end,
  once = true,
})
