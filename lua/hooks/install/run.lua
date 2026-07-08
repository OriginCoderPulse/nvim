--- 同步注册表、安装插件、必要时自动重启
---@param active_specs? table
---@param disabled_specs? table
return function(active_specs, disabled_specs)
	local Pack = _G.Pack
	local sort = require("hooks.install.sort")
	local eager = require("hooks.load.eager")
	active_specs = active_specs or Pack.active
	disabled_specs = disabled_specs or Pack.idle

	Pack.sync(active_specs, disabled_specs)
	Pack.repair()
	local sorted = sort(active_specs)
	if not sorted then
		vim.notify("install 已中止: 依赖排序失败", vim.log.levels.ERROR)
		return
	end
	vim.pack.add(sorted, { confirm = false, load = false })
	eager()
	Pack.relaunch()
end
