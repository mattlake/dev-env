-- The master branch is frozen and does not support Neovim 0.12: it treats query
-- match values as bare TSNodes, but 0.11+ made them arrays of nodes, which
-- crashed markdown injection on every fenced code block. main is the supported
-- branch for 0.12. It drops the highlight, indent, incremental_selection and
-- auto_install modules -- Neovim provides the first two, auto_install is
-- reinstated below, and incremental_selection is gone.
local ensure_installed = {
	"bash",
	"bicep",
	"c_sharp",
	"css",
	"dart",
	"gitignore",
	"glsl",
	"go",
	"gomod",
	"gosum",
	"gotmpl",
	"gowork",
	"heex",
	"html",
	"javascript",
	"json",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"query",
	"toml",
	"typescript",
	"vim",
	"vimdoc",
	"vue",
	"xml",
	"yaml",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup()

		local function attach(buf, lang)
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			if not pcall(vim.treesitter.start, buf, lang) then
				return
			end
			-- Treesitter indentation is flagged experimental upstream.
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		-- Async, so it does not block startup.
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(ts.get_installed(), lang)
		end, ensure_installed)
		if #missing > 0 then
			ts.install(missing)
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UsersTreesitter", { clear = true }),
			callback = function(event)
				local lang = vim.treesitter.language.get_lang(event.match)
				if not lang then
					return
				end

				if vim.tbl_contains(ts.get_installed(), lang) then
					attach(event.buf, lang)
					return
				end

				-- Stand-in for master's auto_install, for anything upstream ships.
				if not vim.tbl_contains(ts.get_available(), lang) then
					return
				end
				ts.install({ lang }):await(function()
					vim.schedule(function()
						attach(event.buf, lang)
					end)
				end)
			end,
		})
	end,
}
