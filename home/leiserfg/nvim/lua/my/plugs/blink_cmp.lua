return {
  "blink.cmp",
  event = "DeferredUIEnter",
  on_require = "blink",
  after = function()
    require("blink.cmp").setup {
      snippets = {
        preset = "luasnip",
      },
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      signature = { enabled = true },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
        },
      },
    }
  end,
}

