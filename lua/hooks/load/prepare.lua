local notify_once = require("hooks.util.notify_once")
local identity = require("hooks.register.identity")

---@param P table
---@return boolean
return function(P)
	local Pack = _G.Pack
	identity(P)
	if not P.name then
		notify_once("load:noname", "load: 无法解析插件名", vim.log.levels.ERROR)
		return false
	end

	if not P._registered and not Pack.registry[P.name] then
		notify_once(
			"load:unregistered:" .. P.name,
			"load(" .. P.name .. "): 未调用 Pack.register，已拒绝",
			vim.log.levels.ERROR
		)
		return false
	end

	return true
end
