return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			highlight_overrides = {
				mocha = function(C)
					return {
						LineNr = { fg = C.overlay1 },
					}
				end,
			},
			integrations = {
				dap = true,
			},
		})
		vim.cmd([[colorscheme catppuccin-mocha]])
	end,
}
