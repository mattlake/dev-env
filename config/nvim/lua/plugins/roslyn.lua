return {
	"seblyng/roslyn.nvim",
	ft = "cs",
	---@module 'roslyn.config'
	---@type RoslynNvimConfig
	opts = {},
	config = function(_, opts)
		vim.lsp.config("roslyn", {
			settings = {
				["csharp|background_analysis"] = {
					-- Match the old AnalyzeOpenDocumentsOnly behaviour; full-solution
					-- analysis is too heavy for the onecloud monorepo.
					dotnet_analyzer_diagnostics_scope = "openFiles",
					dotnet_compiler_diagnostics_scope = "openFiles",
				},
				["csharp|completion"] = {
					dotnet_show_completion_items_from_unimported_namespaces = true,
					dotnet_show_name_completion_suggestions = true,
				},
				["csharp|symbol_search"] = {
					dotnet_search_reference_assemblies = true,
				},
				["csharp|formatting"] = {
					dotnet_organize_imports_on_format = true,
				},
			},
		})
		require("roslyn").setup(opts)
	end,
}
