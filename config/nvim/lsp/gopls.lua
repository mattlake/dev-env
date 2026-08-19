-- cmd is intentionally omitted: mason prepends its bin directory to PATH, and
-- nvim-lspconfig's bundled gopls config already defaults to a bare "gopls".
-- Hardcoding the mason path (as lsp/omnisharp.lua does) would break on Windows,
-- where mason produces gopls.exe/gopls.cmd rather than an extensionless binary.
return {
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
			analyses = {
				unusedparam = true,
				unusedwrite = true,
				nilness = true,
				shadow = true,
			},
			-- Inlay hints pay for themselves in matrix and vertex-attribute code,
			-- where the types are the whole point and the names are all one letter.
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}
