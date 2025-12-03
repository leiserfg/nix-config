require "my/options"
require "my/keymap"
require "my/snackbar"

vim.cmd.colorscheme "notebook"

local map = vim.keymap.set
local opts = { silent = true, expr = true }

map("i", "<c-j>", function()
  return require("luasnip").expand_or_jumpable() and "<Plug>luasnip-expand-or-jump" or "<c-j>"
end, opts)
map("i", "<c-k>", function()
  return require("luasnip").jumpable(-1) and "<Plug>luasnip-jump-prev" or "<c-k>"
end, opts)

map("i", "<c-e>", function()
  return require("luasnip").choice_active() and "<Plug>luasnip-next-choice" or "<c-e>"
end, opts)

map("s", "<c-j>", function()
  require("luasnip").jump(1)
end, { silent = true })
map("s", "<c-k>", function()
  require("luasnip").jump(-1)
end, { silent = true })
map("v", "<c-f>", function()
  require("luasnip.extras.otf").on_the_fly()
end, { silent = true })
map("i", "<c-f>", function()
  require("luasnip.extras.otf").on_the_fly "e"
end, { silent = true })

require("lze").load {
  {
    "luasnip",
    on_require = "luasnip",
    after = function()
      require "my/snippets"
      require("luasnip.loaders.from_vscode").lazy_load()
      local ls = require "luasnip"
      local types = require "luasnip.util.types"
      ls.config.set_config {
        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text = { { "choiceNode", "IncSearch" } } },
          },
          [types.insertNode] = { passive = { hl_group = "Substitute" } },
          [types.exitNode] = { passive = { hl_group = "Substitute" } },
        },
        updateevents = "TextChanged,TextChangedI",
        store_selection_keys = "<c-j>",
      }
    end,
  },
  {
    "friendly-snippets",
    dep_of = "luasnip",
  },
  {
    "tiny-inline-diagnostic.nvim",
    after = function()
      require("tiny-inline-diagnostic").setup {
        profile = "powerline",
      }
      vim.diagnostic.config { virtual_text = false } -- Disable Neovim's default virtual text diagnostics
    end,
  },

  {
    "blink.cmp",

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

    -- cmd = { "" },
    event = "DeferredUIEnter",
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd "wildfire"
    end,

    after = function(plugin)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "<filetype>" },
        callback = function()
          vim.treesitter.start()
        end,
      })

      require("wildfire").setup {
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      }
    end,
  },
  {
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
  },
  {
    "vim-suda",
    after = function()
      vim.g.suda_smart_edit = 1
    end,
  },
  {
    "quicker.nvim",
    ft = "qf",
    after = function()
      require("quicker").setup()
    end,
  },
  {
    "mini.nvim",
    event = "DeferredUIEnter",
    after = function(plugin)
      for _, mini in ipairs {
        "jump",
        "align",
        "move",
        "splitjoin",
        "icons",
      } do
        require(("mini.%s"):format(mini)).setup {}
      end

      local ai = require "mini.ai"
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }

      require("mini.icons").mock_nvim_web_devicons()

      require("mini.pairs").setup {
        mappings = {
          ["'"] = {
            action = "closeopen",
            pair = "''",
            neigh_pattern = "[^'].",
            register = { cr = false },
          },
          ['"'] = {
            action = "closeopen",
            pair = '""',
            neigh_pattern = '[^\\"].',
            register = { cr = false },
          },
        },
      }
      -- I'm an old dog, so I keep using tpope's surround keybindings
      require("mini.surround").setup {
        custom_surroundings = {
          -- lua string
          l = {
            input = { "%[%[().-()%]%]" },
            output = { left = "[[", right = "]]" },
          },

          -- nix string
          n = {
            input = { "%'%'().-()%'%'" },
            output = { left = "''", right = "''" },
          },

          -- python multiline string
          p = {
            input = { '%"%"%"().-()%"%"%"' },
            output = { left = '"""', right = '"""' },
          },
        },

        mappings = {
          add = "ys",
          delete = "ds",
          find = "",
          find_left = "",
          highlight = "",
          replace = "cs",
          update_n_lines = "",
          -- -- Add this only if you don't want to use extended mappings
          -- suffix_last = '',
          -- suffix_next = '',
        },
        search_method = "cover_or_next",
      }

      -- Remap adding surrounding to Visual mode selection
      vim.api.nvim_del_keymap("x", "ys")
      vim.api.nvim_set_keymap(
        "x",
        "S",
        [[:<C-u>lua MiniSurround.add('visual')<CR>]],
        { noremap = true }
      )
      -- Make special mapping for "add surrounding for line"
      vim.api.nvim_set_keymap("n", "yss", "ys_", { noremap = false })

      require("mini.bracketed").setup {
        comment = { suffix = "k" }, -- I use c for changes as diffmode does by default
      }

      local miniclue = require "mini.clue"
      miniclue.setup {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
        },

        clues = {
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      }
    end,
  },
  {
    "vim-startuptime",

    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "lualine.nvim",
    event = "DeferredUIEnter",
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd "lualine-lsp-progress"
    end,
    after = function(plugin)
      require("lualine").setup {
        extensions = { "quickfix", "man" },
        options = {
          component_separators = "",
          section_separators = "",
          globalstatus = true,
          icons_enabled = false,
        },
        sections = {
          lualine_b = {
            {
              require "my/lualine_rec",
              "lsp_progress",
            },
          },
        },
      }
    end,
  },
  {
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

        -- Navigation
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

        -- Actions
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

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end

      gs.setup { on_attach = config }
    end,
  },
  {
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
  },
  {
    "typst-preview-nvim",
    ft = { "typst" },
    after = function()
      require("typst-preview.nvim").setup {
        dependencies_bin = { ["tinymist"] = "tinymist", ["websocat"] = "websocat" },
      }
    end,
  },

  {
    "conform.nvim",
    keys = {
      { "<leader>=", desc = "Format" },
    },
    after = function(plugin)
      local conform = require "conform"
      conform.setup {
        formatters_by_ft = {
          lua = { "stylua" },
          json = { "jq" },
          sh = { "shellcheck", "shfmt" },
          toml = { "taplo" },
          typst = { "typstyle" },
        },
      }

      vim.keymap.set({ "n", "v" }, "<leader>=", function()
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        }
      end, { desc = "Format" })
    end,
  },
}

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
  { "plenary.nvim", on_require = "plenary" },
  {
    "render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    after = function()
      require("render-markdown").setup()
    end,
  },
  { "gitlinker.nvim" },
  {
    "dial.nvim",
    event = "DeferredUIEnter",
    after = function()
      local dm = require "dial.map"
      local augend = require "dial.augend"

      local kms = vim.keymap.set

      kms("n", "<C-A>", dm.inc_normal(), { noremap = true })
      kms("n", "<C-X>", dm.dec_normal(), { noremap = true })
      kms("v", "<C-A>", dm.inc_visual(), { noremap = true })
      kms("v", "<C-X>", dm.dec_visual(), { noremap = true })
      kms("v", "g<C-A>", dm.inc_gvisual(), { noremap = true })
      kms("v", "g<C-X>", dm.dec_gvisual(), { noremap = true })

      local function words(vals)
        return augend.constant.new {
          elements = vals,
          word = true,
          cyclic = true,
        }
      end

      local default = {
        augend.date.alias["%Y-%m-%d"],
        augend.semver.alias.semver,
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.constant.alias.bool,
        words { "staging", "production" },
      }

      local function ftd(others)
        -- Fallback To Default
        return vim.list_extend(others, default)
      end

      require("dial.config").augends:register_group { default = default }
      require("dial.config").augends:on_filetype {
        typescript = ftd {
          words { "let", "const" },
        },
        markdown = ftd {
          augend.misc.alias.markdown_header,
        },
        python = ftd {
          words { "True", "False" },
        },
        csv = ftd {
          words { "True", "False" },
        },
      }
    end,
  },
  {
    "gx.nvim",
    cmd = { "Browse" },
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    config = {
      handlers = {
        rust = {
          name = "rust",
          filename = "Cargo.toml", -- or the necessary filename
          handle = function(mode, line, _)
            local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")

            if crate then
              return "https://crates.io/crates/" .. crate
            end
          end,
        },

        pypi = {
          name = "pypi",
          filename = "pyproject.toml", -- or the necessary filename
          handle = function(mode, line, _)
            local pkg = require("gx.helper").find(line, mode, "(%w+)%s-=%s")

            if pkg then
              return "https://pypi.org/project/" .. pkg
            end
          end,
        },

        jira = {
          name = "jira",
          handle = function(mode, line, _)
            local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
            if ticket and #ticket < 20 then
              return "https://group-one.atlassian.net/browse/" .. ticket
            end
          end,
        },
      },
    },
  },
  { "copilot.lua", cmd = "Copilot" }, -- only for doing :Copilot auth
  {
    "codecompanion.nvim",
    after = function()
      require("codecompanion").setup {
        ignore_warnings = true,
        strategies = {
          chat = {
            adapter = "copilot",
            model = "claude-4-5-sonnet",
          },
          inline = {
            adapter = "copilot",
            model = "claude-4-5-sonnet",
          },
          agent = {
            adapter = "copilot",
            model = "claude-4-5-sonnet",
          },
        },

        memory = {
          opts = {
            chat = {
              enabled = true,
            },
          },
        },

        prompt_library = {
          ["JJ Code Review"] = {
            strategy = "chat",
            description = "Code review",
            prompts = {
              {
                role = "system",
                content = "You are an experienced developer which makes good but not too verbose comments and avoids bullshit chat",
              },
              {
                role = "user",
                content = function()
                  return string.format(
                    [[Review the changes in the diff bellow. Don't do a resume of the changes, just comment what you see wrong or remarcable. Whenever it makes sence, include the file and number line.
              In case of change request, include a diff. Changes:

  ```diff
  %s
  ```
              ]],
                    vim.fn.system "jj diff '@..trunk()'"
                  )
                end,
              },
            },
          },
          ["Code Review"] = {
            strategy = "chat",
            description = "Code review",
            prompts = {
              {
                role = "system",
                content = "You are an experienced developer which makes good but not too verbose comments and avoids bullshit chat",
              },
              {
                role = "user",
                content = function()
                  return string.format(
                    [[Review the changes in the diff bellow. Don't do a resume of the changes, just comment what you see wrong or remarcable. Whenever it makes sence, include the file and number line.
              In case of change request, include a diff. Changes:

  ```diff
  %s
  ```
              ]],
                    vim.fn.system "git diff --no-ext-diff $(git symbolic-ref refs/remotes/origin/HEAD --short)..HEAD"
                  )
                end,
              },
            },
          },
        },
      }
    end,
  },
}
