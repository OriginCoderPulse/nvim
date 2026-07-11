---@param dir string
---@return string
local function path_to_module_prefix(dir)
	return (dir:gsub("\\", "/"):gsub("/", "."))
end

---@param config string
---@return string? dir
---@return string? prefix
return function(config)
	if config:find("[/\\]") then
		local dir = vim.fs.normalize(config)
		if vim.fn.isdirectory(dir) ~= 1 then
			return nil, nil
		end
		local lua_root = vim.fs.normalize(vim.fn.stdpath("config") .. "/lua")
		local norm_dir = vim.fs.normalize(dir)
		if norm_dir:sub(1, #lua_root) == lua_root then
			local rel = norm_dir:sub(#lua_root + 2)
			return norm_dir, path_to_module_prefix(rel)
		end
		vim.notify("Pack.boot: 目录不在 config/lua 下，无法解析模块名: " .. dir, vim.log.levels.ERROR)
		return nil, nil
	end

	local prefix = config
	local dir = vim.fs.normalize(vim.fn.stdpath("config") .. "/lua/" .. prefix:gsub("%.", "/"))
	if vim.fn.isdirectory(dir) ~= 1 then
		vim.notify("Pack.boot: 配置目录不存在: " .. dir, vim.log.levels.ERROR)
		return nil, nil
	end
	return dir, prefix
end
