local ls = require "luasnip"
-- local l = require("luasnip.extras").l
-- local rep = require("luasnip.extras").rep
-- local fmt = require("luasnip.extras.fmt").fmt
-- local sn = ls.sn

local s = ls.s
local t = ls.t
local i = ls.i
local f = ls.f
local c = ls.c
local sn = ls.sn
local fmt = require("luasnip.extras.fmt").fmt

local sp = require "luasnip.nodes.snippetProxy"

math.randomseed(os.time())

local function uuid()
  local random = math.random
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  local out = nil
  local function subs(c)
    local v = (((c == "x") and random(0, 15)) or random(8, 11))
    return string.format("%x", v)
  end

  out = template:gsub("[xy]", subs)
  return out
end

local LOREM_IPSUM =
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

local function sf(trig, body, reg_trig)
  return s({ trig = trig, regTrig = reg_trig, wordTrig = true }, { f(body, {}), i(0) })
end

local function replace_each(replacer)
  local function wrapper(args)
    local len = #args[1][1]
    return { replacer:rep(len) }
  end

  return wrapper
end

local function date()
  return { os.date "%Y-%m-%d" }
end

local function uuid_()
  return { uuid() }
end

local function lorem(_, snp)
  local amount = tonumber(snp.captures[1])
  if amount == nil then
    return { LOREM_IPSUM }
  else
    return { LOREM_IPSUM:sub(1, amount) }
  end
end

vim.filetype.add {
  pattern = {
    [".*.spec.ts"] = "jest.typescript",
  },
}

ls.add_snippets(nil, {
  jest = {
    sp('3"', [["""${1:$TM_SELECTED_TEXT}"""]]),
  },
  python = {
    s(
      "for",
      fmt(
        [[
  for {} in {}:
      
  ]],
        {
          i(1, "it"),
          i(2, "iterator"),
        }
      )
    ),
  },

  direnv = {
    s(
      { wordTrig = true, trig = "lay" },
      { t { "layout " }, i(1, { "python" }), i(0, {}) }
    ),
  },
  all = {
    -- ls.snippet({ trig = "bade" }, { ls.insert_node(1, "é") }),
    -- ls.snippet({ trig="bad..." }, { ls.insert_node(1, "…") }),
    --
    ls.parser.parse_snippet(
      "abc",
      [[``` ${1|a,b,c|} title=\"${2:title}\"${3: linenums=\"1\"}${4: hl_lines=\"\"}","${5:printf(\"%s\\n\", code);} ```\n\n$0"]]
    ),

    sf("date", date),
    sf("uuid", uuid_),
    sf("lorem(%d*)", lorem, true),
    s({ trig = "bbox" }, {
      t { "\226\149\148" },
      f(replace_each "\226\149\144", { 1 }),
      t { "\226\149\151", "\226\149\145" },
      i(1, { "content" }),
      t { "\226\149\145", "\226\149\154" },
      f(replace_each "\226\149\144", { 1 }),
      t { "\226\149\157" },
      i(0, "asd"),
    }),
  },
})

vim.keymap.set(
  { "i", "s" },
  "<c-u>",
  require "luasnip.extras.select_choice",
  { desc = "luasnip select choice" }
)

vim.cmd [[
    inoremap <c-t> <cmd>lua require("luasnip.extras.select_choice")()<cr>
]]

