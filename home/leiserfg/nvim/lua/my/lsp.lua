local function toggle_inlay()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

local function setup_lsp(server_name, config)
  vim.lsp.config(server_name, config)
  vim.lsp.enable(server_name)
end

local mappings = {
  ["<Leader>lq"] = vim.diagnostic.setloclist,
  ["<Leader>li"] = toggle_inlay,
}

for shortcut, callback in pairs(mappings) do
  vim.keymap.set("n", shortcut, callback, { noremap = true, silent = true })
end

-- Setup default capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Simple servers with default config
local simple_servers = {
  "gdscript",
  "vimls",
  "clangd",
  "terraformls",
  "glsl_analyzer",
  "uiua",
  "ruff",
  "tinymist",
  "ty",
  "nushell",
}

for _, server in ipairs(simple_servers) do
  setup_lsp(server, {
    capabilities = capabilities,
  })
end

-- Markdown LS (mpls) with preview command
setup_lsp("mpls", {
  capabilities = capabilities,
  cmd = { "mpls", "--enable-emoji", "--enable-footnotes", "--no-auto" },
  filetypes = { "markdown" },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "MplsOpenPreview", function()
      local params = {
        command = "open-preview",
      }
      client.request("workspace/executeCommand", params, function(err, _)
        if err then
          vim.notify("Error executing command: " .. err.message, vim.log.levels.ERROR)
        else
          vim.notify("Preview opened", vim.log.levels.INFO)
        end
      end)
    end, {
      desc = "Preview markdown with mpls",
    })
  end,
})

-- Lua LS
setup_lsp("lua_ls", {
  capabilities = capabilities,
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      formatters = {
        ignoreComments = true,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { "nixCats", "vim" },
        disable = { "missing-fields" },
      },
      telemetry = { enabled = false },
    },
  },
})

-- Nix LS
setup_lsp("nixd", {
  capabilities = capabilities,
  filetypes = { "nix" },
  settings = {
    nixd = {
      -- nixpkgs = {
      --   expr = nixCats.extra "nixdExtras.nixpkgs" or [[import <nixpkgs> {}]],
      -- },
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
})

setup_lsp("pytest_lsp", {
  cmd = { "pytest-language-server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "pytest.ini", ".git" },
})
