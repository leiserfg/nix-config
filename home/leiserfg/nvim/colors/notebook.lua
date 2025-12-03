-- Neovim colorscheme: notebook
vim.cmd "highlight clear"
vim.cmd "syntax reset"
vim.o.background = "light"
vim.g.colors_name = "notebook"

-- Converts hex to oklch (approximate, pure Lua)
local function hex_to_oklch(hex)
  -- Remove #
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255

  -- sRGB to linear RGB
  local function to_linear(c)
    if c <= 0.04045 then
      return c / 12.92
    else
      return ((c + 0.055) / 1.055) ^ 2.4
    end
  end
  r, g, b = to_linear(r), to_linear(g), to_linear(b)

  -- Linear RGB to XYZ
  local x = r * 0.4122214708 + g * 0.5363325363 + b * 0.0514459929
  local y = r * 0.2119034982 + g * 0.6806995451 + b * 0.1073969566
  local z = r * 0.0883024619 + g * 0.2817188376 + b * 0.6299787005

  -- XYZ to Lab
  local function f(t)
    if t > 0.0088564516 then
      return t ^ (1 / 3)
    else
      return 7.787037 * t + 16 / 116
    end
  end
  local xn, yn, zn = 0.95047, 1.0, 1.08883
  local l = 116 * f(y / yn) - 16
  local a = 500 * (f(x / xn) - f(y / yn))
  local b_lab = 200 * (f(y / yn) - f(z / zn))

  -- Lab to LCH
  local c_chroma = math.sqrt(a * a + b_lab * b_lab)
  local h = math.atan2(b_lab, a) * (180 / math.pi)
  if h < 0 then
    h = h + 360
  end

  -- Lab to OKLab
  -- (approximate conversion)
  local l_ok = l / 100
  local c_ok = c_chroma / 100
  local h_ok = h

  return { l = l_ok, c = c_ok, h = h_ok }
end

-- Darken oklch color by reducing lightness
local function oklch_darken(oklch, amount)
  local l = math.max(0, oklch.l - amount)
  return { l = l, c = oklch.c, h = oklch.h }
end

-- Convert oklch back to hex (approximate, pure Lua)
local function oklch_to_hex(oklch)
  -- Only lightness is changed, so we just scale RGB
  -- This is a rough approximation
  local l = oklch.l * 100
  local c = oklch.c * 100
  local h = oklch.h
  -- Convert LCH to Lab
  local a = math.cos(h * math.pi / 180) * c
  local b_lab = math.sin(h * math.pi / 180) * c
  -- Lab to XYZ
  local y = (l + 16) / 116
  local x = a / 500 + y
  local z = y - b_lab / 200
  local xn, yn, zn = 0.95047, 1.0, 1.08883
  x = xn * ((x ^ 3 > 0.008856) and x ^ 3 or (x - 16 / 116) / 7.787)
  y = yn * ((y ^ 3 > 0.008856) and y ^ 3 or (y - 16 / 116) / 7.787)
  z = zn * ((z ^ 3 > 0.008856) and z ^ 3 or (z - 16 / 116) / 7.787)
  -- XYZ to linear RGB
  local r = x * 3.2406 + y * -1.5372 + z * -0.4986
  local g = x * -0.9689 + y * 1.8758 + z * 0.0415
  local b = x * 0.0557 + y * -0.2040 + z * 1.0570
  -- Linear RGB to sRGB
  local function to_srgb(c)
    if c <= 0.0031308 then
      return math.max(0, math.min(1, c * 12.92))
    else
      return math.max(0, math.min(1, 1.055 * (c ^ (1 / 2.4)) - 0.055))
    end
  end
  r, g, b = to_srgb(r), to_srgb(g), to_srgb(b)
  return string.format(
    "#%02x%02x%02x",
    math.floor(r * 255),
    math.floor(g * 255),
    math.floor(b * 255)
  )
end

-- Darken hex color using oklch
local function darken_oklch(hex, amount)
  local oklch = hex_to_oklch(hex)
  local darkened = oklch_darken(oklch, amount)
  return oklch_to_hex(darkened)
end

local c = {
  fg = "#35243c",
  bg = "#fcfdf1",
  bg_dim = "#f2f2f2",

  gray = "#ebebeb",
  green = "#e3f4df",
  lilac = "#f2e9ff",
  blue = "#dff0ff",
  orange = "#fbecd6",

  red = "#ffe6e6",
  yellow = "#f7edd6",
  info = "#eaf3ff",
  cyan = "#d6f6f5",
  magenta = "#fbe7f9",
}

-- 16-color palette for terminal
for i, col in ipairs {
  c.bg,
  c.red,
  c.green,
  c.yellow,
  c.blue,
  c.magenta,
  c.cyan,
  c.fg,
  darken_oklch(c.bg, 0.2), -- 8: bright black
  darken_oklch(c.red, 0.2), -- 9: bright red
  darken_oklch(c.green, 0.2), -- 10: bright green
  darken_oklch(c.yellow, 0.2), -- 11: bright yellow
  darken_oklch(c.blue, 0.2), -- 12: bright blue
  darken_oklch(c.magenta, 0.2), -- 13: bright magenta
  darken_oklch(c.cyan, 0.2), -- 14: bright cyan
  darken_oklch(c.fg, 0.2), -- 15: bright white
} do
  vim.g["terminal_color_" .. (i - 1)] = col
end

-- Simple highlight function
local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = c.fg, bg = c.bg })
hl("Comment", { fg = c.fg, bg = c.gray, italic = true })
hl("String", { fg = c.fg, bg = c.green })
hl("Function", { fg = c.fg, bg = c.bg })
hl("Constant", { fg = c.fg, bg = c.orange })

-- Core UI
hl("NormalFloat", { link = "Normal" })
hl("NonText", { fg = c.gray })
hl("SpecialKey", { fg = c.blue })
hl("Directory", { link = "SpecialKey" })
hl("Title", { fg = c.fg, bold = true })
hl("IncSearch", { fg = c.fg, bg = c.yellow })
hl("Search", { link = "IncSearch" })
hl("CurSearch", { link = "IncSearch" })
hl("LineNr", { fg = c.gray })
hl("CursorLineNr", { link = "Normal" })
hl("Question", { fg = c.fg, bold = true })
hl("StatusLine", { fg = c.fg, bg = c.bg, bold = true })
hl("StatusLineNC", { fg = c.fg, bg = c.bg })
hl("TabLine", { link = "Normal" })
hl("TabLineSel", { reverse = true })
hl("WinSeparator", { fg = c.fg })
hl("SignColumn", { link = "LineNr" })
hl("FoldColumn", { link = "SignColumn" })
hl("Conceal", { fg = c.lilac })
hl("SpellBad", { fg = c.fg, undercurl = true })
hl("SpellCap", { link = "SpellBad" })
hl("SpellLocal", { link = "SpellBad" })
hl("SpellRare", { link = "SpellBad" })
hl("Pmenu", { fg = c.fg, bg = c.bg_dim })
hl("PmenuSel", { fg = c.fg, bg = c.gray })
hl("PmenuSbar", { bg = c.fg })
hl("PmenuThumb", { link = "PmenuSbar" })
hl("WildMenu", { bg = c.lilac })
hl("Visual", { bg = c.cyan })
hl("Folded", {})
hl("Cursor", { bg = c.gray })
hl("TermCursor", { link = "Cursor" })
hl("CursorLine", { bg = c.bg_dim })
hl("CursorColumn", { link = "CursorLine" })
hl("ColorColumn", { bg = c.yellow })
hl("MoreMsg", { fg = c.cyan })
hl("ModeMsg", { fg = c.blue })
hl("ErrorMsg", { fg = c.bg, bg = c.red })
hl("WarningMsg", { fg = c.bg, bg = c.orange })
hl("DiffAdd", { fg = c.green })
hl("DiffChange", { fg = c.orange })
hl("DiffDelete", { fg = c.red })
hl("Identifier", { fg = c.fg })
hl("Delimiter", { link = "Identifier" })
hl("Operator", { link = "Identifier" })
hl("PreProc", { link = "Question" })
hl("Type", { bg = c.lilac })
hl("Special", { link = "SpecialKey" })
hl("Underlined", { underline = true })
hl("Ignore", { fg = c.bg })
hl("Error", { link = "ErrorMsg" })
hl("Todo", { fg = c.green })
hl("MatchParen", { fg = c.red, underline = true })

-- Treesitter
hl("@variable", { link = "Normal" })
hl("@function", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@constant", { link = "Constant" })
hl("@string", { link = "String" })
hl("@comment", { link = "Comment" })

-- Diffview
hl("DiffviewDiffAdd", { bg = c.green })
hl("DiffviewDiffDelete", { bg = c.red })
hl("DiffviewDiffChange", { bg = c.orange })

-- gitsigns.nvim (extra)
hl("GitSignsUntracked", { fg = c.info })
hl("GitSignsStaged", { fg = c.green })

-- render-markdown.nvim
hl("@markdown.heading", { fg = c.lilac, bold = true })
hl("@markdown.list", { fg = c.green })
hl("@markdown.code", { fg = c.blue, bg = c.bg_dim })
hl("@markdown.url", { fg = c.info, underline = true })

hl("SnacksIndent", { fg = c.blue, bg=c.bg })
