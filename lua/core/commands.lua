-- === 自定义命令 ===

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	local targets = #opts.fargs > 0 and opts.fargs or nil
	local force = opts.bang
	if targets then
		vim.notify("Checking updates for: " .. table.concat(targets, ", "), vim.log.levels.INFO)
	else
		vim.notify("Checking updates for all plugins...", vim.log.levels.INFO)
	end
	vim.pack.update(targets, { force = force })
end, {
	nargs = "*",
	bang = true,
	complete = PackUtils.complete_plugin_names,
	desc = "Update plugins (use ! to skip confirmation)",
})

vim.api.nvim_create_user_command("PackStatus", function(opts)
	local targets = #opts.fargs > 0 and opts.fargs or nil
	vim.pack.update(targets, { offline = true })
end, {
	nargs = "*",
	complete = PackUtils.complete_plugin_names,
	desc = "Check plugin status without downloading",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "LSP: Go To Definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "LSP: Go To Declaration" })
		vim.keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float({ bufnr = event.buf, source = true })
		end, { buffer = event.buf, desc = "LSP: Line Diagnostics" })
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	pattern = "*",
	nested = true,
	callback = function()
		vim.fn.execute("silent! write!")
		require("conform").format({ async = true, timeout_ms = 3000 })
	end,
})
