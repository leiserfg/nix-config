return {
  "luasnip",
  on_require = "luasnip",
  after = function()
    require "my/snippets"
    require("luasnip.loaders.from_vscode").lazy_load()
    local ls = require "luasnip"
    local types = require "luasnip.util.types"
    ls.config.set_config {
      ext_opts = {
        [types.choiceNode] = {
          active = { virt_text = { { "choiceNode", "IncSearch" } } },
        },
        [types.insertNode] = { passive = { hl_group = "Substitute" } },
        [types.exitNode] = { passive = { hl_group = "Substitute" } },
      },
      updateevents = "TextChanged,TextChangedI",
      store_selection_keys = "<c-j>",
    }
  end,
}