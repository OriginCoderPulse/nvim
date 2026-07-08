local state = require("hooks.restart.state")

return function()
	local Pack = _G.Pack
	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.restart then
		return
	end
	Pack._listeners.restart = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackAutoRestart", { clear = true }),
		callback = function(ev)
			if ev.data.kind == "install" then
				state.installed[#state.installed + 1] = ev.data.spec.name
			end
		end,
	})
end
