-- Script-local variable to store the socket path
local kitty_socket = nil

-- Function to get the project root directory
local function get_project_root()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Check if it's a scratch buffer
  if bufname == "" or vim.bo[bufnr].buftype ~= "" then
    return vim.fn.expand "~"
  end

  -- Try to get root from LSP
  local clients = vim.lsp.get_clients { bufnr = bufnr }
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

-- Function to get the socket path for this Neovim instance
local function get_socket_path()
  if kitty_socket then
    return kitty_socket
  end

  -- Create a hash from the servername to ensure uniqueness
  local servername = vim.v.servername
  local hash = vim.fn.sha256(servername):sub(1, 16)
  kitty_socket = string.format("/tmp/kitty-pi-%s.sock", hash)
  return kitty_socket
end

-- Function to check if Kitty is running on the socket
local function is_kitty_running()
  local socket = get_socket_path()

  -- Check if socket file exists
  if vim.fn.filereadable(socket) == 0 then
    return false
  end

  -- Try to communicate with Kitty to verify it's alive
  local result = vim.system({ "kitten", "@", "--to", "unix:" .. socket, "ls" }):wait()
  return result.code == 0
end

-- Function to ensure Kitty is running
local function ensure_kitty_running()
  if is_kitty_running() then
    return true
  end

  local root_dir = get_project_root()
  local socket = get_socket_path()

  -- Launch kitty with remote control enabled
  vim.system {
    "kitty",
    "--detach",
    "--directory=" .. root_dir,
    "-o",
    "allow_remote_control=yes",
    "--listen-on",
    "unix:" .. socket,
    "pi",
  }

  -- Give Kitty a moment to start
  vim.wait(500, function()
    return is_kitty_running()
  end, 100)

  return is_kitty_running()
end

-- Generic function to send text to Pi via Kitty
local function pi_send(text)
  if not ensure_kitty_running() then
    vim.notify("Failed to start or connect to Kitty", vim.log.levels.ERROR)
    return
  end

  local socket = get_socket_path()

  -- Send text via stdin
  local result = vim
    .system({ "kitten", "@", "--to", "unix:" .. socket, "send-text", "--stdin" }, { stdin = text })
    :wait()

  if result.code ~= 0 then
    vim.notify("Failed to send text to Kitty", vim.log.levels.ERROR)
  end
end

-- Function to send selection with context for Pi
local function pi_send_range(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Get the absolute path
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"

  -- Get the filetype
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
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

  pi_send(text)
end

-- Create keybinding to send range to Pi
vim.keymap.set("v", "<leader><leader>r", function()
  -- Get visual selection range
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."

  -- Ensure correct order
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  pi_send_range(start_line, end_line)
end, { desc = "Send selection to Pi" })

vim.keymap.set("n", "<leader><leader>r", function()
  -- In normal mode, send current line
  local line = vim.fn.line "."
  pi_send_range(line, line)
end, { desc = "Send current line to Pi" })

-- Function to send diagnostics to Pi
local function pi_send_diagnostics(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local display_name = filename ~= "" and vim.fn.fnamemodify(filename, ":p") or "[No Name]"

  -- Get diagnostics for the range
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = first_line - 1, end_lnum = last_line - 1 })

  if #diagnostics == 0 then
    vim.notify("No diagnostics in the specified range", vim.log.levels.INFO)
    return
  end

  -- Get the code from the range
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local content = table.concat(lines, "\n")

  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "" then
    filetype = "text"
  end

  -- Format diagnostics
  local diag_text = {}
  table.insert(
    diag_text,
    string.format("Diagnostics for %s (lines %d-%d):\n", display_name, first_line, last_line)
  )

  for _, diag in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diag.severity]
    local line_num = diag.lnum + 1
    table.insert(diag_text, string.format("- Line %d [%s]: %s", line_num, severity, diag.message))
    if diag.source then
      table.insert(diag_text, string.format("  Source: %s", diag.source))
    end
  end

  table.insert(diag_text, string.format("\nCode:\n```%s\n%s\n```\n", filetype, content))

  pi_send(table.concat(diag_text, "\n"))
end

-- Create keybinding to send diagnostics to Pi
vim.keymap.set("v", "<leader><leader>d", function()
  -- Get visual selection range
  local start_line = vim.fn.line "v"
  local end_line = vim.fn.line "."

  -- Ensure correct order
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  pi_send_diagnostics(start_line, end_line)
end, { desc = "Send diagnostics for selection to Pi" })

vim.keymap.set("n", "<leader><leader>d", function()
  -- In normal mode, send diagnostics for entire buffer
  local line_count = vim.api.nvim_buf_line_count(0)
  pi_send_diagnostics(1, line_count)
end, { desc = "Send diagnostics for buffer to Pi" })
