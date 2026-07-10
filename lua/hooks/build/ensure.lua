--- 若存在 build_cmd 且尚未构建，则触发 build
local stamp = require("hooks.build.stamp")
local retry = require("hooks.build.retry")

---@param name string
---@param build_cmd string|string[]|function
return function(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] or not build_cmd then
		return
	end
	local dir = Pack.path(name)
	if not dir or stamp.current(dir, build_cmd) then
		return
	end
	if Pack.building[name] or retry.pending(name) then
		return
	end
	retry.reset(name)
	Pack.build(name, build_cmd)
end
