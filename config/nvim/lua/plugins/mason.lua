return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			-- omnisharp's Mason package is kept installed as a parachute during the
			-- roslyn.nvim migration; v2 auto-enables every installed server, so it
			-- must be excluded or it resurrects on startup. C# is roslyn.nvim's job.
			automatic_enable = {
				exclude = { "omnisharp" },
			},
			ensure_installed = {
				"lua_ls",
				"gopls",
				"vtsls",
				"angularls",
				"yamlls",
			},
		},
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					registries = {
						"github:mason-org/mason-registry",
						"github:Crashdummyy/mason-registry",
					},
				},
			},
			"neovim/nvim-lspconfig",
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = { "prettierd", "netcoredbg", "js-debug-adapter", "roslyn" },
		},
	},
}
