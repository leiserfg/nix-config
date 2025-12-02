local o = vim.opt
local g = vim.g

-- o.commentstring = "/*%s*/"
o.cpo:append(">")
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.modelines = 2
o.synmaxcol = 500
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.hidden = true
o.showmatch = true
o.matchtime = 2
o.errorbells = false
o.visualbell = false
o.timeoutlen = 500
o.splitbelow = true
o.splitright = true
o.joinspaces = false
o.foldlevel = 2
o.grepprg = "rg --vimgrep --no-heading --smart-case"
o.showmode = false
o.expandtab = true
o.list = true
o.showbreak = "↪ "

o.listchars = {
	extends = "⟩",
	nbsp = "␣",
	precedes = "⟨",
	tab = "<~>",
	trail = "•",
}

-- stops line wrapping from being confusing
o.breakindent = true
o.fillchars = { eob = " ", diff = "╱" }
o.virtualedit = "block"
o.shiftwidth = 4
o.softtabstop = 4
o.linebreak = true
o.smartindent = true
o.signcolumn = "yes"
o.inccommand = "split"
o.termguicolors = true
o.shortmess:append("Ic")
o.completeopt = "noinsert,menuone,noselect"
o.swapfile = false
o.pumheight = 20
-- o.diffopt:append "internal,algorithm:patience,vertical"
o.diffopt:append("internal,algorithm:histogram,indent-heuristic,vertical")

-- o.clipboard = "unnamedplus"

o.undofile = true
o.scrolloff = 10

-- Disable providers
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
o.cmdheight = 0
g.mapleader = " "
g.maplocalleader = " "

-- Decrease update time
o.updatetime = 250
o.timeoutlen = 300

local vimrc = vim.api.nvim_create_augroup("vimrc", { clear = false })
local acmd = vim.api.nvim_create_autocmd

acmd("InsertEnter", { group = vimrc, command = "set nohlsearch" })
acmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.md", "*.rst" },
	group = vimrc,
	command = "setlocal spell spelllang=en_us",
})
acmd("BufReadPost", { group = vimrc, command = 'silent! normal! g`"zv' })

local function yank_colors()
	vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
end

acmd("TextYankPost", { group = vimrc, callback = yank_colors })

vim.filetype.add({
	extension = { keymap = "dts", frag = "glsl", ua = "uiua" },
	pattern = { ["*.xml.txt"] = "xml" },
})

-- vim.cmd.colorscheme "notebook"
