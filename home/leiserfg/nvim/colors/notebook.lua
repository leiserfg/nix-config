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
hl("Keyword", { fg = c.fg, bg = c.bg, bold = true })
hl("Function", { fg = c.fg, bg = c.bg })
hl("Constant", { fg = c.fg, bg = c.orange })

hl("DiagnosticError", { fg = c.fg, bg = c.red })
hl("DiagnosticWarn", { fg = c.fg, bg = c.yellow })
hl("DiagnosticInfo", { fg = c.fg, bg = c.info })
hl("DiagnosticHint", { fg = c.fg, bg = c.hint })

hl("CursorLine", { bg = c.bg_dim })
hl("LineNr", { fg = c.bg_dim, bg = c.bg })
hl("CursorLineNr", { fg = "#333333", bg = c.bg_dim })

-- Treesitter highlights (link to base groups)
hl("@variable", { link = "Normal" })
hl("@function", { link = "Function" })
hl("@keyword", { link = "Keyword" })
hl("@constant", { link = "Constant" })
hl("@string", { link = "String" })
hl("@comment", { link = "Comment" })

-- LSP reference highlights
hl("LspReferenceText", { bg = c.bg_dim })
hl("LspReferenceRead", { bg = c.bg_dim })
hl("LspReferenceWrite", { bg = c.bg_dim })

-- GitSigns plugin
hl("GitSignsAdd", { fg = c.green, bg = c.bg })
hl("GitSignsChange", { fg = c.lilac, bg = c.bg })
hl("GitSignsDelete", { fg = c.orange, bg = c.bg })

-- Telescope plugin
hl("TelescopeNormal", { link = "Normal" })
hl("TelescopeBorder", { fg = c.gray, bg = c.bg })
hl("TelescopePromptNormal", { link = "Normal" })
hl("TelescopePromptBorder", { fg = c.gray, bg = c.bg })
hl("TelescopeSelection", { bg = c.bg_dim })

-- NvimTree plugin
hl("NvimTreeNormal", { link = "Normal" })
hl("NvimTreeRootFolder", { fg = c.lilac, bold = true })
hl("NvimTreeGitDirty", { fg = c.lilac })
hl("NvimTreeGitNew", { fg = c.green })
hl("NvimTreeGitDeleted", { fg = c.orange })

-- mini.nvim (MiniStatusline, MiniTabline, MiniCursorword, etc.)
hl("MiniStatuslineModeNormal", { link = "Normal" })
hl("MiniStatuslineModeInsert", { fg = c.bg, bg = c.green, bold = true })
hl("MiniStatuslineModeVisual", { fg = c.bg, bg = c.lilac, bold = true })
hl("MiniStatuslineModeReplace", { fg = c.bg, bg = c.orange, bold = true })
hl("MiniTablineCurrent", { link = "CursorLine" })
hl("MiniTablineVisible", { link = "LineNr" })
hl("MiniTablineHidden", { link = "Comment" })
hl("MiniCursorword", { bg = c.bg_dim })
hl("MiniCursorwordCurrent", { bg = c.bg_dim })

-- hydra.nvim
hl("HydraRed", { fg = c.orange, bold = true })
hl("HydraBlue", { fg = c.blue, bold = true })
hl("HydraHint", { fg = c.fg, bg = c.bg_dim })

-- beacon.nvim
hl("Beacon", { bg = c.lilac })

-- lazy.nvim
hl("LazyNormal", { link = "Normal" })
hl("LazyButtonActive", { fg = c.bg, bg = c.lilac, bold = true })
hl("LazyButton", { fg = c.fg, bg = c.bg_dim })
hl("LazyProgressDone", { fg = c.green })
hl("LazyProgressTodo", { fg = c.gray })

-- which-key.nvim
hl("WhichKey", { fg = c.lilac, bold = true })
hl("WhichKeyGroup", { fg = c.blue })
hl("WhichKeyDesc", { fg = c.green })
hl("WhichKeySeperator", { fg = c.gray })
hl("WhichKeyFloat", { bg = c.bg_dim })

-- leap.nvim
hl("LeapMatch", { fg = c.bg, bg = c.lilac, bold = true })
hl("LeapLabelPrimary", { fg = c.bg, bg = c.blue, bold = true })
hl("LeapLabelSecondary", { fg = c.bg, bg = c.orange, bold = true })

-- dashboard-nvim
hl("DashboardHeader", { fg = c.lilac })
hl("DashboardCenter", { fg = c.blue })
hl("DashboardFooter", { fg = c.gray })
hl("DashboardShortCut", { fg = c.green })

-- lspsaga.nvim
hl("SagaBorder", { fg = c.gray, bg = c.bg })
hl("SagaTitle", { fg = c.lilac, bold = true })
hl("SagaLightBulb", { fg = c.hint })
hl("SagaError", { fg = c.orange })
hl("SagaWarn", { fg = c.lilac })
hl("SagaInfo", { fg = c.info })
hl("SagaHint", { fg = c.hint })

-- rainbow-delimiters.nvim
hl("RainbowDelimiterRed", { fg = c.orange })
hl("RainbowDelimiterYellow", { fg = c.lilac })
hl("RainbowDelimiterBlue", { fg = c.blue })
hl("RainbowDelimiterOrange", { fg = c.orange })
hl("RainbowDelimiterGreen", { fg = c.green })
hl("RainbowDelimiterViolet", { fg = c.gray })
hl("RainbowDelimiterCyan", { fg = c.info })

-- fzf-lua
hl("FzfLuaBorder", { fg = c.gray, bg = c.bg })
hl("FzfLuaTitle", { fg = c.lilac, bold = true })
hl("FzfLuaCursor", { fg = c.bg, bg = c.blue })
hl("FzfLuaSearch", { fg = c.bg, bg = c.green })

-- nvim-bqf
hl("BqfPreviewBorder", { fg = c.gray, bg = c.bg })
hl("BqfPreviewTitle", { fg = c.lilac, bold = true })
hl("BqfPreviewCursor", { fg = c.bg, bg = c.blue })

-- gitsigns.nvim (extra)
hl("GitSignsUntracked", { fg = c.info })
hl("GitSignsStaged", { fg = c.green })

-- render-markdown.nvim
hl("@markdown.heading", { fg = c.lilac, bold = true })
hl("@markdown.list", { fg = c.green })
hl("@markdown.code", { fg = c.blue, bg = c.bg_dim })
hl("@markdown.url", { fg = c.info, underline = true })
