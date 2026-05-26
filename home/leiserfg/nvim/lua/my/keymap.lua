vim.cmd.cabbr("<expr>", "%%", "expand('%:p:h')")

local map = vim.keymap.set
map("i", "<c-c>", "<ESC>", { noremap = true })
map("n", "<leader>w", ":w!<cr>")

map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- Separate nvim registers from system clipboard
vim.keymap.set(
  "i",
  "<C-p>",
  "<C-r><C-p>+",
  { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)
vim.keymap.set(
  "x",
  "<leader>P",
  '"_dP',
  { noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)

