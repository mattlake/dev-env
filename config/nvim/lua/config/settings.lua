vim.g.have_nerd_font = true
vim.opt.title = true
vim.opt.titlestring = [[Nvim: %t]]

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true

-- make searches case-insensitive unless there is an uppercase letter included
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live with :%s
vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Hide the status line as we are using mini-statusline
vim.opt.showmode = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.mouse = "a"

vim.lsp.enable("omnisharp")
vim.lsp.enable("vtsls")
-- angularls requires @angular/language-service in the project's node_modules.
-- If not in package.json, from the Angular project root run:
--   npm install --no-save --no-package-lock --legacy-peer-deps @angular/language-service@<version>
vim.lsp.enable("angularls")
vim.lsp.enable("yamlls")
