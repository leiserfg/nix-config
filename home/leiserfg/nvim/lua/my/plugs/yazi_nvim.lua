return {
  "yazi.nvim",
  event = "DeferredUIEnter",
  keys = {
    {
      "-",
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
  },
  after = function()
    require("yazi").setup { open_for_directories = true }
  end,
}

