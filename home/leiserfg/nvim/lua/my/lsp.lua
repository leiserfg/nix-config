local ld = vim.diagnostic

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

    -- the on require handler will be needed here if you want to use the
    -- fallback method of getting filetypes if you don't provide any
    on_require = { "lspconfig" },
    -- define a function to run over all type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
    end,
    after = function()
      for _, lsp in ipairs {
        "gdscript",
        "vimls",
        "clangd",
        "terraformls",
        "glsl_analyzer",
        "nixd",
        "uiua",
        "ruff",
        "nushell",
      } do
        vim.lsp.enable(lsp)
      end
    end,
  },
  {
    -- name of the lsp
    "lua_ls",
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options.
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
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
    -- also these are regular specs and you can use before and after and all the other normal fields
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
