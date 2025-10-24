return {
	{
		"williamboman/mason.nvim",
		opts = {
			registries = {
				"github:mason-org/mason-registry",
				"github:Crashdummyy/mason-registry",
			},
			ensure_installed = {
				"lua-language-server",
				"angular-language-server",
				"xmlformatter",
				"csharpier",
				"prettier",

				"stylua",
				"bicep-lsp",
				"html-lsp",
				"css-lsp",
				"eslint-lsp",
				"typescript-language-server",
				"json-lsp",
				"rust-analyzer",
				"roslyn",
				"rzls",
			},
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		opts = {
			ensure_installed = {
				"coreclr",
			},
		},
	},
}
