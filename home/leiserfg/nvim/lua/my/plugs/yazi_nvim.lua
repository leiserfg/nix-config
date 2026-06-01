require("yazi").setup { open_for_directories = true }

vim.keymap.set("n", "-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })

