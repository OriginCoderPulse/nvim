--- 加载单个 Lua 模块（custom / 配置文件）
--- Load a single Lua module (custom or config file)
---@param mod string
---@return boolean ok
return function(mod)
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify("Pack.boot: 模块加载失败: " .. mod .. "\n" .. tostring(err), vim.log.levels.ERROR)
	end
	return ok
end
