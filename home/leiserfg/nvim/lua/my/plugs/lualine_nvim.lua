 -- "lualine.nvim"
 -- "lualine-lsp-progress"

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
