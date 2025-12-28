return {
  "conform.nvim",
  keys = {
    { "<leader>=", desc = "Format" },
  },
  after = function(plugin)
    local conform = require "conform"
    conform.setup {
      formatters_by_ft = {
        lua = { "stylua" },
        json = { "jq" },
        sh = { "shellcheck", "shfmt" },
        toml = { "taplo" },
        typst = { "typstyle" },
      },
    }
    vim.keymap.set({ "n", "v" }, "<leader>=", function()
      conform.format {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      }
    end, { desc = "Format" })
  end,
}

