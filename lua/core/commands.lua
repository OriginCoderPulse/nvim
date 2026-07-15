return {
	LspAttach = {
		event = "LspAttach",
		callback = function(event)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "LSP: Go To Definition" })
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "LSP: Go To Declaration" })
			vim.keymap.set("n", "<leader>ld", function()
				vim.diagnostic.open_float({ bufnr = event.buf, source = true })
			end, { buffer = event.buf, desc = "LSP: Line Diagnostics" })
		end,
	},
	AutoFormat = {
		event = { "InsertLeave", "TextChanged" },
		pattern = "*",
		nested = true,
		callback = function()
			if not vim.bo.modifiable or vim.bo.readonly or vim.bo.buftype ~= "" then
				return
			end
			vim.fn.execute("silent! write!")
			local ok, conform = pcall(require, "conform")
			if ok then
				conform.format({ async = true, timeout_ms = 3000 })
			end
		end,
	},
	HelpWindow = {
		event = "FileType",
		pattern = "help",
		command = "wincmd L",
	},
}
