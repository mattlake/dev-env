return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "DAP continue / start" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "DAP step over" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "DAP step into" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "DAP step out" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "DAP toggle UI" },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
			dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

			dap.adapters.coreclr = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
				args = { "--interpreter=vscode" },
				env = {
					DOTNET_ROOT = vim.fn.expand("~/.dotnet"),
					DOTNET_MULTILEVEL_LOOKUP = "0",
				},
			}
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch .NET",
					request = "launch",
					env = {
						ASPNETCORE_ENVIRONMENT = "Development",
						DOTNET_ROOT = vim.fn.expand("~/.dotnet"),
					},
					program = function()
						local dlls = vim.fn.glob(vim.fn.getcwd() .. "/**/bin/Debug/**/*.dll", false, true)
						dlls = vim.tbl_filter(function(dll)
							if dll:match("/ref/") or dll:match("%.resources%.dll$") then
								return false
							end
							local dll_name = vim.fn.fnamemodify(dll, ":t:r")
							return dll:match("/" .. dll_name:gsub("%-", "%%-") .. "/bin/")
						end, dlls)
						if #dlls == 0 then
							vim.notify("No debug dlls found. Run dotnet build first.", vim.log.levels.WARN)
							return dap.ABORT
						end
						if #dlls == 1 then
							return dlls[1]
						end
						local co = coroutine.running()
						vim.ui.select(dlls, {
							prompt = "Select dll:",
							format_item = function(dll)
								return vim.fn.fnamemodify(dll, ":.:h:h:h") .. " → " .. vim.fn.fnamemodify(dll, ":t")
							end,
						}, function(selected)
							coroutine.resume(co, selected or dap.ABORT)
						end)
						return coroutine.yield()
					end,
				},
			}

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}
			dap.configurations.typescript = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch TypeScript file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
			}
			dap.configurations.javascript = dap.configurations.typescript
		end,
	},
}
