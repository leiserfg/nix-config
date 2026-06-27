local ls = require "luasnip"
ls.cleanup()
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
local parse = require("luasnip.util.parser").parse_snippet

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

ls.add_snippets(nil, {
  python = {
    parse("for", [[
for ${1:it} in ${2:iterator}:
    ${3}
]]),
    parse("class", [[
class ${1:MyClass}${2:(BaseClass)}:
    """${3:Docstring}"""
    def __init__(self${4:}):
        ${5:pass}
]]),
    parse("def", [[
def ${1:function_name}(${2:args}):
    """${3:Docstring}"""
    ${4:pass}
]]),
    parse("defm", [[
def ${1:method_name}(self${2:}):
    """${3:Docstring}"""
    ${4:pass}
]]),
  },

  direnv = {
    s({ wordTrig = true, trig = "lay" }, { t { "layout " }, i(1, { "python" }), i(0, {}) }),
  },
  all = {
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
