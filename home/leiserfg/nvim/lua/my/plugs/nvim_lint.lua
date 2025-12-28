return {
  "nvim-lint",
  event = "FileType",
  after = function(plugin)
    require("lint").linters_by_ft = {
      nix = { "nix" },
      sh = { "shellcheck" },
    }
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}

