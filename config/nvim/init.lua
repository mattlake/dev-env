require("config.lazy")
require("config.settings")
require("config.keymap")
require("neotest").setup({
	adapters = {
		require("neotest-dotnet"),
	},
})
