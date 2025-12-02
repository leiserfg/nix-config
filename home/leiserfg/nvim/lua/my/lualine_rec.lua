local lualine = require "lualine"
vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function()
    lualine.refresh {
      place = { "statusline" },
    }
  end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    -- Delay the `vim.fn.reg_recording` as nvim takes some time to clean it
    local timer = vim.loop.new_timer()
    timer:start(
      50,
      0,
      vim.schedule_wrap(function()
        lualine.refresh {
          place = { "statusline" },
        }
      end)
    )
  end,
})

local Rec = require("lualine.component"):extend()
function Rec:init(options)
  Rec.super.init(self, options)
  -- Todo, get color from theme
  local icon_color = require("lualine.utils.utils").extract_color_from_hllist(
    { "fg", "sp" },
    { "DiagnosticError", "LspDiagnosticsDefaultError", "DiffDelete" },
    "#e32636"
  )
  self.icon_hg = self:create_hl({ fg = icon_color }, "macro_icon")
end

function Rec:update_status()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return table.concat {
      self:format_hl(self.icon_hg),
      "󰑋 ",
      self:get_default_hl(),
      "@",
      recording_register,
    }
  end
end

return Rec
