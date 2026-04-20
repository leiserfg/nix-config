# Notebook theme for Nushell

# Core colors (from notebook.nvim)
# fg is dark purple, bg is cream/white, other colors are light/pastel
const c_fg = "#35243c"      # dark purple (used as text on light backgrounds)
const c_bg = "#fcfdf1"      # cream white
const c_bg_dim = "#f2f2f2"  # light gray
const c_gray = "#ebebeb"    # gray
const c_green = "#e3f4df"   # light green
const c_lilac = "#f2e9ff"   # light lilac
const c_blue = "#dff0ff"    # light blue
const c_orange = "#fbecd6"  # light orange
const c_red = "#ffe6e6"     # light red
const c_yellow = "#f7edd6"  # light yellow
const c_info = "#eaf3ff"    # light blue
const c_cyan = "#d6f6f5"    # light cyan
const c_magenta = "#fbe7f9" # light magenta

# Table and display configuration
$env.config.table.mode = "rounded"

# Color configuration for primitive values and UI elements
# Matches notebook.nvim: dark fg on colored bg for highlights
$env.config.color_config = {
  # Separators and spacing
  separator: $c_gray
  leading_trailing_space_bg: $c_bg_dim

  # Table elements - header uses lilac bg like nvim
  header: { fg: $c_fg bg: $c_lilac attr: b }
  row_index: { fg: $c_fg bg: $c_cyan attr: b }
  empty: $c_bg_dim

  # Primitive types - dark text on colored backgrounds (like nvim hl)
  bool: { fg: $c_fg bg: $c_green }
  int: { fg: $c_fg bg: $c_blue }
  float: { fg: $c_fg bg: $c_orange }
  filesize: { fg: $c_fg bg: $c_cyan }
  datetime: { fg: $c_fg bg: $c_magenta }
  duration: { fg: $c_fg bg: $c_bg_dim }
  range: { fg: $c_fg bg: $c_yellow }
  string: { fg: $c_fg bg: $c_green }
  nothing: { fg: $c_fg bg: $c_red }
  binary: { fg: $c_fg bg: $c_red }
  cell-path: { fg: $c_fg bg: $c_blue }
  hints: { fg: $c_fg bg: $c_gray }

  # Syntax highlighting shapes - matching nvim theme pattern
  # Dark fg on colored bg, bold for keywords
  shape_garbage: { fg: $c_bg bg: $c_red attr: b }
  shape_bool: { fg: $c_fg bg: $c_green }
  shape_int: { fg: $c_fg bg: $c_blue }
  shape_float: { fg: $c_fg bg: $c_orange }
  shape_range: { fg: $c_fg bg: $c_yellow }
  shape_decimal: { fg: $c_fg bg: $c_orange }
  shape_internalcall: { fg: $c_fg bg: $c_cyan }
  shape_external: { fg: $c_fg bg: $c_cyan }
  shape_externalarg: { fg: $c_fg bg: $c_green }
  shape_literal: { fg: $c_fg bg: $c_orange }
  shape_operator: { fg: $c_fg bg: $c_yellow }
  shape_signature: { fg: $c_fg bg: $c_green }
  shape_string: { fg: $c_fg bg: $c_green }
  shape_string_interpolation: { fg: $c_fg bg: $c_cyan }
  shape_filepath: { fg: $c_fg bg: $c_cyan }
  shape_globpattern: { fg: $c_fg bg: $c_blue }
  shape_variable: { fg: $c_fg bg: $c_magenta }
  shape_flag: { fg: $c_fg bg: $c_blue }
  shape_custom: { fg: $c_fg bg: $c_bg }
  shape_block: { fg: $c_fg bg: $c_lilac }
  shape_list: { fg: $c_fg bg: $c_cyan }
  shape_record: { fg: $c_fg bg: $c_cyan }
  shape_table: { fg: $c_fg bg: $c_lilac }
  shape_nothing: { fg: $c_fg bg: $c_red }
}


# LS_COLORS for 'ls' command - using terminal ANSI colors
$env.LS_COLORS = $"di=1;38;2;53;36;60:fi=38;2;53;36;60:ln=38;2;137;74;189:*.nu=38;2;127;183;194:*.lua=38;2;186;149;175:*.md=38;2;168;189;227:*.toml=38;2;186;107;77:*.json=38;2;186;107;77:*.yaml=38;2;161;181;108:*.yml=38;2;161;181;108:*.sh=38;2;247;237;214:*.zsh=38;2;247;237;214:*.fish=38;2;247;237;214"

# Make sure ANSI coloring is enabled
$env.config.use_ansi_coloring = true
