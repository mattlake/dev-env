return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"gopls",
				"vtsls",
				"angularls",
				"yamlls",
				"omnisharp",
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
			ensure_installed = { "prettierd", "netcoredbg", "js-debug-adapter" },
		},
	},
}
