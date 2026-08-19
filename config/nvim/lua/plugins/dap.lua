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

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })

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

			-- Install delve from Homebrew on macOS, NOT mason: dlv needs task_for_pid
			-- to control a process, which requires a codesigned binary. Mason builds it
			-- with `go install`, unsigned, and it fails at launch. On Windows there is
			-- no signing requirement, so `go install .../cmd/dlv@latest` is fine there.
			-- Either way dlv is resolved from PATH.
			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
					-- dlv must not be detached on Windows or it never terminates.
					detached = vim.fn.has("win32") == 0,
				},
			}

			-- NOTE: breakpoints inside a cgo/OpenGL render loop stall the window and
			-- the OS may mark the app unresponsive. Use these for game logic, collision,
			-- level loading and tests; use an on-screen overlay for per-frame problems.
			dap.configurations.go = {
				{
					type = "delve",
					name = "Debug package",
					request = "launch",
					program = "${fileDirname}",
				},
				{
					type = "delve",
					name = "Debug test",
					request = "launch",
					mode = "test",
					program = "${fileDirname}",
				},
				{
					type = "delve",
					name = "Attach to process",
					request = "attach",
					mode = "local",
					processId = function()
						return require("dap.utils").pick_process()
					end,
				},
			}
		end,
	},
}
