return {
	LSPLineDiagnostics = {
		event = "LspAttach",
		callback = function(event)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "LSP: Go To Definition" })
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "LSP: Go To Declaration" })
			vim.keymap.set("n", "<leader>ld", function()
				vim.diagnostic.open_float({ bufnr = event.buf, source = true })
			end, { buffer = event.buf, desc = "LSP: Line Diagnostics" })
		end,
	},
	HelpWindow = {
		event = "FileType",
		pattern = "help",
		command = "wincmd L",
	},
}
