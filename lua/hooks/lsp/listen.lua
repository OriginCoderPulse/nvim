local state = require("hooks.lsp.state")
local sync = require("hooks.lsp.sync")

return function()
	if state.listened then
		return
	end
	state.listened = true
	vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
		group = vim.api.nvim_create_augroup("PackLsp", { clear = true }),
		callback = function(args)
			sync(args.buf, args.event == "FileType")
		end,
	})
end
