-- Function to get the project root directory
local function get_project_root()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Check if it's a scratch buffer
  if bufname == "" or vim.bo[bufnr].buftype ~= "" then
    return vim.fn.expand "~"
  end

  -- Try to get root from LSP
  local clients = vim.lsp.get_active_clients { bufnr = bufnr }
  if #clients > 0 then
    for _, client in ipairs(clients) do
      if client.config.root_dir then
        return client.config.root_dir
      end
    end
  end

  -- Try to find git root
  local git_root = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(vim.fn.expand "%:p:h") .. " rev-parse --show-toplevel"
  )[1]
  if git_root and vim.v.shell_error == 0 then
    return git_root
  end

  -- Fall back to file's directory or home
  if bufname ~= "" then
    return vim.fn.expand "%:p:h"
  else
    return vim.fn.expand "~"
  end
end

-- Function to launch Pi in Kitty
local function launch_pi()
  local root_dir = get_project_root()

  -- Launch kitty in detached mode with pi
  local cmd = string.format("kitty --detach --directory=%s pi &", vim.fn.shellescape(root_dir))

  vim.fn.system(cmd)
end

-- Function to yank selection with context for Pi
local function pi_yank(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Get just the filename without full path
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":t") or "[No Name]"

  -- Get the filetype
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if filetype == "" then
    filetype = "text"
  end

  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")

  -- Create the formatted text
  local text = string.format(
    "Given this fragment of %s in the range from line %d to %d:\n\n```%s\n%s\n```\n",
    display_name,
    first_line,
    last_line,
    filetype,
    content
  )

  -- Copy to system clipboard
  vim.fn.setreg("+", text)
end

-- Create the command
vim.api.nvim_create_user_command("Pi", function(opts)
  -- If there's a range selection, call PiYank first
  if opts.range > 0 then
    pi_yank(opts.line1, opts.line2)
  end
  launch_pi()
end, {
  range = true,
  desc = "Launch Pi in a new Kitty instance at project root (and yank selection if any)",
})

-- Create the PiYank command
vim.api.nvim_create_user_command("PiYank", function(opts)
  pi_yank(opts.line1, opts.line2)
end, {
  range = true,
  desc = "Copy selection with context for Pi",
})
