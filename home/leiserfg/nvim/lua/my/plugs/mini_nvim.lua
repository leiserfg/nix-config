return {
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
    require("mini.hipatterns").setup {
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      },
    }
    require("mini.surround").setup {
      custom_surroundings = {
        l = {
          input = { "%[%[().-()%]%]" },
          output = { left = "[[", right = "]]" },
        },
        n = {
          input = { "%'%'().-()%'%'" },
          output = { left = "''", right = "''" },
        },
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
      },
      search_method = "cover_or_next",
    }
    vim.api.nvim_del_keymap("x", "ys")
    vim.api.nvim_set_keymap(
      "x",
      "S",
      [[:<C-u>lua MiniSurround.add('visual')<CR>]],
      { noremap = true }
    )
    vim.api.nvim_set_keymap("n", "yss", "ys_", { noremap = false })
    require("mini.bracketed").setup {
      comment = { suffix = "k" },
    }
    local miniclue = require "mini.clue"
    miniclue.setup {
      triggers = {
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        { mode = "n", keys = "'" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "'" },
        { mode = "x", keys = "`" },
        { mode = "n", keys = '"' },
        { mode = "x", keys = '"' },
        { mode = "i", keys = "<C-r>" },
        { mode = "c", keys = "<C-r>" },
        { mode = "n", keys = "<C-w>" },
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
}

