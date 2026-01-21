return {
  "gitsigns.nvim",
  event = "DeferredUIEnter",
  after = function()
    local gs = require "gitsigns"
    local function config(bufnr)
      local function map(mode, l, r, opts)
        opts = (opts or {})
        opts.buffer = bufnr
        return vim.keymap.set(mode, l, r, opts)
      end
      map("n", "]c", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          gs.nav_hunk "next"
        end)
        return "<Ignore>"
      end, { expr = true })
      map("n", "[c", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          gs.nav_hunk "prev"
        end)
        return "<Ignore>"
      end, { expr = true })
      map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
      map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
      map("n", "<leader>hS", gs.stage_buffer)
      map("n", "<leader>hu", gs.undo_stage_hunk)
      map("n", "<leader>hR", gs.reset_buffer)
      map("n", "<leader>hp", gs.preview_hunk)
      map("n", "<leader>hb", function()
        gs.blame_line { full = true }
      end)
      map("n", "<leader>tb", gs.toggle_current_line_blame)
      map("n", "<leader>hd", gs.diffthis)
      map("n", "<leader>hD", function()
        gs.diffthis "~"
      end)
      map("n", "<leader>td", gs.toggle_deleted)
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end
    gs.setup { on_attach = config }
  end,
}
