vim.keymap.set("n", "-", "<cmd>Oil --float<CR>", { desc = "Open parent directory in Oil file explorer" })

vim.keymap.set("n", "gl", function()
	vim.diagnostic.open_float()
end, { desc = "Open diagnostics in a float" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wx", "<C-w>c", { desc = "Close current split" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Equalise split sizes" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
