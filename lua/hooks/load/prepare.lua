local notify_once = require("hooks.util.notify_once")

---@param P table
---@return boolean
return function(P)
	local Pack = _G.Pack
	Pack.identity(P)
	if not P.name then
		notify_once("load:noname", "Pack.load: 无法解析插件名", vim.log.levels.ERROR)
		return false
	end

	if not P._registered and not Pack.registry[P.name] then
		notify_once(
			"load:unregistered:" .. P.name,
			"Pack.load(" .. P.name .. "): 未调用 Pack.register(P)，已拒绝 load",
			vim.log.levels.ERROR
		)
		return false
	end

	return true
end
