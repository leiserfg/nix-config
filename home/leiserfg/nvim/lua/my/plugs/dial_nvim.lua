return {
  "dial.nvim",
  event = "DeferredUIEnter",
  after = function()
    local dm = require "dial.map"
    local augend = require "dial.augend"
    local kms = vim.keymap.set
    kms("n", "<C-A>", dm.inc_normal(), { noremap = true })
    kms("n", "<C-X>", dm.dec_normal(), { noremap = true })
    kms("v", "<C-A>", dm.inc_visual(), { noremap = true })
    kms("v", "<C-X>", dm.dec_visual(), { noremap = true })
    kms("v", "g<C-A>", dm.inc_gvisual(), { noremap = true })
    kms("v", "g<C-X>", dm.dec_gvisual(), { noremap = true })
    local function words(vals)
      return augend.constant.new {
        elements = vals,
        word = true,
        cyclic = true,
      }
    end
    local default = {
      augend.date.alias["%Y-%m-%d"],
      augend.semver.alias.semver,
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.constant.alias.bool,
      words { "staging", "production" },
    }
    local function ftd(others)
      return vim.list_extend(others, default)
    end
    require("dial.config").augends:register_group { default = default }
    require("dial.config").augends:on_filetype {
      typescript = ftd {
        words { "let", "const" },
      },
      markdown = ftd {
        augend.misc.alias.markdown_header,
      },
      python = ftd {
        words { "True", "False" },
      },
      csv = ftd {
        words { "True", "False" },
      },
    }
  end,
}