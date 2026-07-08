--- 注册 PackChanged(install) 后重试 eager 依赖
return function()
	local Pack = _G.Pack
	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.load then
		return
	end
	Pack._listeners.load = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackLoadListen", { clear = true }),
		callback = function(ev)
			if ev.data.kind == "install" then
				vim.schedule(require("hooks.load.eager"))
			end
		end,
	})
end
