local state = require("hooks.lsp.state")
local sync = require("hooks.lsp.sync")

return function()
	if state.listened then
		return
	end
	state.listened = true
	vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufDelete", "BufWipeout" }, {
		group = vim.api.nvim_create_augroup("PackLsp", { clear = true }),
		callback = function(args)
			local force = args.event == "FileType"
				or args.event == "BufDelete"
				or args.event == "BufWipeout"
			sync(args.buf, force)
		end,
	})
end
