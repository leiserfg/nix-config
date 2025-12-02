require "my/options"
require "my/keymap"
require "my/snackbar"

-- vim.cmd.colorscheme("onedark")

require("lze").load {
  {
    "blink.cmp",
    enabled = nixCats "general" or false,
    event = "DeferredUIEnter",
    on_require = "blink",
    after = function()
      require("blink.cmp").setup {
        snippets = {
          preset = "luasnip",
        },

        keymap = {
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"] = { "hide", "fallback" },
          ["<CR>"] = { "accept", "fallback" },

          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },

          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        signature = { enabled = true },
        completion = {
          documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },

        sources = {
          default = {
            "lsp",
            "snippets",
            "path",
            "buffer",
          },
        },
      }
    end,
  },
  {
    "nvim-treesitter",
    enabled = nixCats "general" or false,
    -- cmd = { "" },
    event = "DeferredUIEnter",
    load = function(name)
      vim.cmd.packadd(name)
      -- vim.cmd.packadd "treesitter-modules"
    end,

    after = function(plugin)

      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "<filetype>" },
        callback = function()
          vim.treesitter.start()
        end,
      })

      -- require("treesitter-modules").setup {
      --   highlight = { enable = true },
      --   indent = { enable = false },
      --   incremental_selection = {
      --     enable = true,
      --     keymaps = {
      --       init_selection = "<c-space>",
      --       node_incremental = "<c-space>",
      --       scope_incremental = "<c-s>",
      --       node_decremental = "<M-space>",
      --     },
      --   },
      -- }
    end,
  },
  {
    "mini.nvim",
    enabled = nixCats "general" or false,
    event = "DeferredUIEnter",
    after = function(plugin)
      require("mini.pairs").setup()
      require("mini.icons").setup()
      require("mini.ai").setup()
    end,
  },
  {
    "vim-startuptime",
    enabled = nixCats "general" or false,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "lualine.nvim",
    enabled = nixCats "general" or false,
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd "lualine-lsp-progress"
    end,
    after = function(plugin)
      require("lualine").setup {
        options = {
          icons_enabled = false,
          theme = "onedark",
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_c = {
            {
              "filename",
              path = 1,
              status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              "filename",
              path = 3,
              status = true,
            },
          },
          lualine_x = { "filetype" },
        },
        tabline = {
          lualine_a = { "buffers" },
          lualine_b = { "lsp_progress" },
          lualine_z = { "tabs" },
        },
      }
    end,
  },
  {
    "gitsigns.nvim",
    enabled = nixCats "general" or false,
    event = "DeferredUIEnter",
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("gitsigns").setup {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ "n", "v" }, "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to next hunk" })

          map({ "n", "v" }, "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to previous hunk" })

          -- Actions
          -- visual mode
          map("v", "<leader>hs", function()
            gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, { desc = "stage git hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
          end, { desc = "reset git hunk" })
          -- normal mode
          map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
          map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
          map("n", "<leader>gb", function()
            gs.blame_line { full = false }
          end, { desc = "git blame line" })
          map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
          map("n", "<leader>gD", function()
            gs.diffthis "~"
          end, { desc = "git diff against last commit" })

          -- Toggles
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
          map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
        end,
      }
      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
  {
    "which-key.nvim",
    enabled = nixCats "general" or false,
    event = "DeferredUIEnter",
    after = function(plugin)
      require("which-key").setup {}
      require("which-key").add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>f", group = "[f]ind" },
        { "<leader>f_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      }
    end,
  },
  {
    "nvim-lint",
    enabled = nixCats "general" or false,
    event = "FileType",
    after = function(plugin)
      require("lint").linters_by_ft = {
        -- NOTE: download some linters in lspsAndRuntimeDeps
        -- and configure them here
        -- markdown = {'vale',},
        -- javascript = { 'eslint' },
        -- typescript = { 'eslint' },
        go = nixCats "go" and { "golangcilint" } or nil,
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  {
    "conform.nvim",
    enabled = nixCats "general" or false,
    keys = {
      { "<leader>FF", desc = "[F]ormat [F]ile" },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require "conform"

      conform.setup {
        formatters_by_ft = {
          -- NOTE: download some formatters in lspsAndRuntimeDeps
          -- and configure them here
          lua = nixCats "lua" and { "stylua" } or nil,
          go = nixCats "go" and { "gofmt", "golint" } or nil,
          -- templ = { "templ" },
          -- Conform will run multiple formatters sequentially
          -- python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          -- javascript = { { "prettierd", "prettier" } },
        },
      }

      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        }
      end, { desc = "[F]ormat [F]ile" })
    end,
  },
}

local function lsp_on_attach(_, bufnr)
  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

  if nixCats "general" then
    nmap("gr", function()
      Snacks.picker.lsp_references()
    end, "[G]oto [R]eferences")
    nmap("gI", function()
      Snacks.picker.lsp_implementations()
    end, "[G]oto [I]mplementation")
    nmap("<leader>ds", function()
      Snacks.picker.lsp_symbols()
    end, "[D]ocument [S]ymbols")
    nmap("<leader>ws", function()
      Snacks.picker.lsp_workspace_symbols()
    end, "[W]orkspace [S]ymbols")
  end

  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })
end

-- NOTE: Register a handler from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger vim.lsp.enable and the rtp config collection only on the correct filetypes
-- it adds the lsp field used below
-- (and must be registered before any load calls that use it!)
require("lze").register_handlers(require("lzextras").lsp)
-- also replace the fallback filetype list retrieval function with a slightly faster one
require("lze").h.lsp.set_ft_fallback(function(name)
  return dofile(
    nixCats.pawsible { "allPlugins", "opt", "nvim-lspconfig" } .. "/lsp/" .. name .. ".lua"
  ).filetypes or {}
end)
require("lze").load {
  {
    "nvim-lspconfig",
    enabled = nixCats "general" or false,
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
        on_attach = lsp_on_attach,
      })
    end,
  },
  {
    -- name of the lsp
    "lua_ls",
    enabled = nixCats "lua" or false,
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
    "gopls",
    enabled = nixCats "go" or false,
    -- if you don't provide the filetypes it asks lspconfig for them using the function we set above
    lsp = {
      -- filetypes = { "go", "gomod", "gowork", "gotmpl" },
    },
  },
  {
    "nixd",
    enabled = nixCats "nix" or false,
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          -- nixd requires some configuration.
          -- luckily, the nixCats plugin is here to pass whatever we need!
          -- we passed this in via the `extra` table in our packageDefinitions
          -- for additional configuration options, refer to:
          -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          nixpkgs = {
            -- in the extras set of your package definition:
            -- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
            expr = nixCats.extra "nixdExtras.nixpkgs" or [[import <nixpkgs> {}]],
          },
          options = {
            nixos = {
              -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
              expr = nixCats.extra "nixdExtras.nixos_options",
            },
            ["home-manager"] = {
              -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
              expr = nixCats.extra "nixdExtras.home_manager_options",
            },
          },
          formatting = {
            command = { "alejandra" },
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
}
