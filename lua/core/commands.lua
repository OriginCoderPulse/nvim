local update = require("hooks.update").update
local complete = require("hooks.update.complete")
local rebuild = require("hooks.build.rebuild")
local failed = require("hooks.build.failed")

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	local targets = #opts.fargs > 0 and opts.fargs or nil
	local force = opts.bang
	if targets then
		vim.notify("Checking updates for: " .. table.concat(targets, ", "), vim.log.levels.INFO)
	else
		vim.notify("Checking updates for all plugins...", vim.log.levels.INFO)
	end
	update(targets, { force = force })
end, {
	nargs = "*",
	bang = true,
	complete = complete,
	desc = "Update plugins (use ! to skip confirmation)",
})

vim.api.nvim_create_user_command("PackStatus", function(opts)
	local targets = #opts.fargs > 0 and opts.fargs or nil
	update(targets, { offline = true })
end, {
	nargs = "*",
	complete = complete,
	desc = "Check plugin status without downloading",
})

vim.api.nvim_create_user_command("PackReBuild", function(opts)
	local targets = #opts.fargs > 0 and opts.fargs or nil
	rebuild(targets, { force = opts.bang })
end, {
	nargs = "*",
	bang = true,
	complete = function(arg_lead)
		arg_lead = arg_lead or ""
		local cmds = require("hooks.build.cmds")
		local lead = arg_lead:lower()
		local failed_set, out = {}, {}
		for _, name in ipairs(failed.list()) do
			if cmds.get(name) and name:lower():find(lead, 1, true) == 1 then
				failed_set[name] = true
				out[#out + 1] = name
			end
		end
		local rest = {}
		for name in pairs(cmds.all()) do
			if not failed_set[name] and name:lower():find(lead, 1, true) == 1 then
				rest[#rest + 1] = name
			end
		end
		table.sort(rest)
		for _, name in ipairs(rest) do
			out[#out + 1] = name
		end
		return out
	end,
	desc = "Rebuild failed (or specified) plugins; use ! to force",
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
		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format({ async = true, timeout_ms = 3000 })
		end
	end,
})
