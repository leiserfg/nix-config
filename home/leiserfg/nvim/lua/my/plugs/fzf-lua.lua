local fzf = require "fzf-lua"
fzf.setup {
  -- fzf_bin = "sk",
  winopts = { treesitter = false },
  fzf_colors = true,
}
fzf.register_ui_select()
local function grep()
  return fzf.grep { no_esc = true }
end
local function ast_grep()
  fzf.fzf_live("ast-grep --context 0 --heading never --pattern <query> 2>/dev/null", {
    exec_empty_query = false,
    multiprocess = true,
    previewer = "builtin",
    preview_opts = "hidden",
    actions = {
      ["default"] = require("fzf-lua").actions.file_edit,
      ["ctrl-q"] = {
        fn = require("fzf-lua").actions.file_edit_or_qf,
        prefix = "select-all+",
      },
    },
  })
end
local map = vim.keymap.set
for shortcut, callback in pairs {
  ["<leader>ff"] = fzf.files,
  ["<leader>fr"] = fzf.registers,
  ["<leader>fb"] = fzf.buffers,
  ["<leader>fh"] = fzf.help_tags,
  ["<leader>fz"] = fzf.builtin,
  ["<leader>fa"] = ast_grep,
  ["<leader>/"] = grep,
  ["z="] = fzf.spell_suggest,
} do
  map("n", shortcut, callback, { noremap = true })
end
