return {
  "gx.nvim",
  cmd = { "Browse" },
  keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
  config = {
    handlers = {
      rust = {
        name = "rust",
        filename = "Cargo.toml",
        handle = function(mode, line, _)
          local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")
          if crate then
            return "https://crates.io/crates/" .. crate
          end
        end,
      },
      pypi = {
        name = "pypi",
        filename = "pyproject.toml",
        handle = function(mode, line, _)
          local pkg = require("gx.helper").find(line, mode, "(%w+)%s-=%s")
          if pkg then
            return "https://pypi.org/project/" .. pkg
          end
        end,
      },
      jira = {
        name = "jira",
        handle = function(mode, line, _)
          local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
          if ticket and #ticket < 20 then
            return "https://group-one.atlassian.net/browse/" .. ticket
          end
        end,
      },
    },
  },
}