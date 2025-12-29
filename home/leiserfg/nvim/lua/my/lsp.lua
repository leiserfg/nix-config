local function toggle_inlay()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

local mappings = {
  ["<Leader>lq"] = vim.diagnostic.setloclist,
  ["<Leader>li"] = toggle_inlay,
}

for shortcut, callback in pairs(mappings) do
  vim.keymap.set("n", shortcut, callback, { noremap = true, silent = true })
end

-- NOTE: Register a handler from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger vim.lsp.enable and the rtp config collection only on the correct filetypes
-- it adds the lsp field used below
-- (and must be registered before any load calls that use it!)
require("lze").register_handlers(require("lzextras").lsp)
-- replace the fallback filetype list retrieval function with a slightly faster one
require("lze").h.lsp.set_ft_fallback(function(name)
  return dofile(
    nixCats.pawsible { "allPlugins", "opt", "nvim-lspconfig" } .. "/lsp/" .. name .. ".lua"
  ).filetypes or {}
end)

require("lze").load {
  {
    "nvim-lspconfig",
    -- event = "DeferredUIEnter",
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
    end,
  },

  { "gdscript", lsp = {} },
  { "vimls", lsp = {} },
  { "clangd", lsp = {} },
  { "terraformls", lsp = {} },
  { "glsl_analyzer", lsp = {} },
  { "uiua", lsp = {} },
  { "ruff", lsp = {} },
  { "nushell", lsp = {} },
  { "pyrefly", lsp = {} },
  {
    "lua_ls",
    lsp = {
      filetypes = { "lua" },
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixCats", "vim" },
            disable = { "missing-fields" },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    "nixd",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = nixCats.extra "nixdExtras.nixpkgs" or [[import <nixpkgs> {}]],
          },
          formatting = {
            command = { "nixfmt" },
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with",
            },
          },
        },
      },
    },
  },
  { "rustaceanvim" },
  {
    "typescript-tools.nvim",
    ft = { "typscript" },
    after = function()
      require("typescript-tools").setup()
    end,
  },
}
