--- 插件 setup 之后执行 var 中 use=true 的 callback（每个插件仅一次）
--- After plugin setup, run var use=true callbacks (once per plugin)
local notify_once = require("hooks.util.notify_once")

---@param plugin_name string
---@param use_list { name: string, callback: function }[]
---@return boolean ok
return function(plugin_name, use_list)
	if type(use_list) ~= "table" or #use_list == 0 then
		return true
	end

	local Pack = _G.Pack
	Pack.var_used = Pack.var_used or {}
	if Pack.var_used[plugin_name] then
		return true
	end

	for _, item in ipairs(use_list) do
		local ok, err = pcall(item.callback)
		if not ok then
			notify_once(
				"handle:var_use:" .. plugin_name .. ":" .. item.name,
				"Pack.handle:load(" .. plugin_name .. "): var." .. item.name .. " callback failed\n" .. tostring(err),
				vim.log.levels.ERROR
			)
			-- 失败不标记 var_used，允许下次重试
			-- Do not mark var_used on failure so next load can retry
			return false
		end
	end

	Pack.var_used[plugin_name] = true
	return true
end
