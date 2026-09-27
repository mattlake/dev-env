return {
	"seblyng/roslyn.nvim",
	ft = "cs",
	---@module 'roslyn.config'
	---@type RoslynNvimConfig
	opts = {},
	-- vim.lsp.config must run in init (at startup), not config: the plugin's
	-- plugin/roslyn.lua calls vim.lsp.enable("roslyn") when lazy sources it,
	-- which synchronously starts the client for the already-open buffer —
	-- BEFORE lazy runs config(). Anything registered in config() misses the
	-- first client.
	init = function()
		vim.lsp.config("roslyn", {
			settings = {
				["csharp|background_analysis"] = {
					-- Match the old AnalyzeOpenDocumentsOnly behaviour; full-solution
					-- analysis is too heavy on a large solution.
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
			handlers = {
				-- roslyn.nvim's stock handler calls vim.lsp.diagnostic._refresh(),
				-- which nvim 0.12 nightlies removed. Reimplement it: announce init,
				-- then re-pull diagnostics for attached buffers (pulls sent before
				-- project init return empty results). Drop when upstream fixes it.
				["workspace/projectInitializationComplete"] = function(_, _, ctx)
					vim.notify("Roslyn project initialization complete", vim.log.levels.INFO, { title = "roslyn.nvim" })

					vim.api.nvim_exec_autocmds("User", {
						pattern = "RoslynInitialized",
						modeline = false,
						data = { client_id = ctx.client_id },
					})

					local client = vim.lsp.get_client_by_id(ctx.client_id)
					if client then
						for bufnr in pairs(client.attached_buffers) do
							if vim.api.nvim_buf_is_loaded(bufnr) then
								client:request("textDocument/diagnostic", {
									textDocument = vim.lsp.util.make_text_document_params(bufnr),
								}, nil, bufnr)
							end
						end
					end
				end,
			},
		})
	end,
}
