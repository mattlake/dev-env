return {
	"folke/trouble.nvim",
	dependencies = { "echasnovski/mini.icons" },
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document diagnostics (Trouble)" },
		{ "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics (Trouble)" },
		{
			"]x",
			function() require("trouble").next({ skip_groups = true, jump = true }) end,
			desc = "Next trouble item",
		},
		{
			"[x",
			function() require("trouble").prev({ skip_groups = true, jump = true }) end,
			desc = "Prev trouble item",
		},
	},
	opts = {
		position = "bottom",
		height = 15,
		auto_close = false,
		focus = true,
	},
}
