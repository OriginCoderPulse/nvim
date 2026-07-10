--- 监听 PackChanged，安装/更新后自动重新构建（单一 autocmd，按插件名查表）
--- Listen PackChanged; rebuild after install/update (one autocmd, lookup by plugin name)
local stamp = require("hooks.build.stamp")
local build_cmds = {}

---@param name string
---@param build_cmd string|string[]|function
return function(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] or not build_cmd then
		build_cmds[name] = nil
		return
	end
	build_cmds[name] = build_cmd

	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.build then
		return
	end
	Pack._listeners.build = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackBuildListen", { clear = true }),
		callback = function(ev)
			local cmd = build_cmds[ev.data.spec.name]
			if cmd and (ev.data.kind == "update" or ev.data.kind == "install") then
				stamp.clear(ev.data.path)
				Pack.build(ev.data.spec.name, cmd)
			end
		end,
	})
end
