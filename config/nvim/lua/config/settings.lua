vim.g.have_nerd_font = true

-- Show relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999

-- share the clipboard
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true -- stores undo history betwwen sessions

-- make searches case-insensitive unless there is an uppercase letter included
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- enable signcolumn
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live with :%s
vim.opt.inccommand = "split"

-- which line am i on?
vim.opt.cursorline = true

-- highlight yanks
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Hide the status line as we are using mini-statusline
vim.opt.showmode = false

-- Tab and indentation settings
vim.opt.expandtab = true -- Converts tabs to spaces
vim.opt.shiftwidth = 4 -- indent depth
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.mouse = "a" -- Enable the mouse for rezing windows etc
