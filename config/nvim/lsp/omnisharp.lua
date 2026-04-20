local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/omnisharp"

return {
	cmd = { mason_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
	filetypes = { "cs", "vb" },
	root_dir = function(bufnr, on_dir)
		local path = vim.api.nvim_buf_get_name(bufnr)
		local sln = vim.fs.find(function(name)
			return name:match("%.sln$") or name:match("%.slnx$")
		end, { upward = true, path = vim.fs.dirname(path), limit = 1 })
		if #sln > 0 then
			on_dir(vim.fs.dirname(sln[1]))
			return
		end
		local csproj = vim.fs.find(function(name)
			return name:match("%.csproj$")
		end, { upward = true, path = vim.fs.dirname(path), limit = 1 })
		if #csproj > 0 then
			on_dir(vim.fs.dirname(csproj[1]))
		end
	end,
	settings = {
		FormattingOptions = {
			EnableEditorConfigSupport = true,
			OrganizeImports = true,
		},
		MsBuild = {
			-- Only load projects when files within them are opened, not all at once.
			-- This is the key setting that makes omnisharp start fast with large solutions.
			LoadProjectsOnDemand = true,
		},
		RoslynExtensionsOptions = {
			EnableAnalyzersSupport = true,
			EnableImportCompletion = true,
			AnalyzeOpenDocumentsOnly = true,
		},
		Sdk = {
			IncludePrereleases = false,
		},
	},
}
