vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UsersLspConfig", {  }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
        map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")
        map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("fzf-lua").lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Server-side hint settings (see lsp/gopls.lua) only make the server
        -- offer hints; they still have to be switched on per buffer.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "[T]oggle inlay [H]ints")
        end
    end,
})
