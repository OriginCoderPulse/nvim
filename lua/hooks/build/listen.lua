--- 登记 build_cmd：已安装未构建则立即 ensure；并监听 PackChanged 在安装/更新后立刻重建
--- Register build_cmd: ensure immediately if installed-but-unbuilt; rebuild on PackChanged install/update
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
	-- 打开 Neovim / 登记时：磁盘已有插件但无 stamp → 立刻 build（不等懒加载）
	-- On open/register: installed but no stamp → build now (do not wait for lazy load)
	Pack.ensure(name, build_cmd)

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
				-- 安装/更新完成立即重建，不等插件 load / UI 启动事件
				-- Rebuild as soon as install/update finishes; do not wait for plugin load / UI
				stamp.clear(ev.data.path)
				Pack.build(ev.data.spec.name, cmd)
			end
		end,
	})
end
