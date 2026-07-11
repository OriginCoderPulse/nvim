--- 登记 build；PackChanged(install/update) 只清 stamp，真正构建留给安装后 batch
--- Register build; PackChanged only clears stamp — batch runs after install
local stamp = require("hooks.build.stamp")
local cmds = require("hooks.build.cmds")

---@param name string
---@param build string|string[]|function
return function(name, build)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] or not build then
		cmds.set(name, nil)
		return
	end
	cmds.set(name, build)

	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.build then
		return
	end
	Pack._listeners.build = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackBuildListen", { clear = true }),
		callback = function(ev)
			if not cmds.get(ev.data.spec.name) then
				return
			end
			if ev.data.kind == "update" or ev.data.kind == "install" then
				-- 仅失效 stamp；统一构建在 install 结束后的 batch
				-- Invalidate stamp only; unified build runs in post-install batch
				stamp.clear(ev.data.path)
			end
		end,
	})
end
