return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nsidorenco/neotest-vstest",
			"mfussenegger/nvim-dap",
		},
		keys = {
			{ "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
			{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
			{ "<leader>ts", function() require("neotest").run.run({ suite = true }) end, desc = "Run test suite" },
			{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
			{ "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
			{ "<leader>tS", function() require("neotest").summary.toggle() end, desc = "Test summary" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vstest")({
				dap_settings = {
					type = "coreclr",
					name = "netcoredbg - attach",
					request = "attach",
					justMyCode = false,
				},
			}),
				},
			})
		end,
	},
}
