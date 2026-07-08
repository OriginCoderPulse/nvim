---@param dir string
---@param prefix string
---@return boolean ok
return function(dir, prefix)
	local failed = false
	local files = {}
	for name, ftype in vim.fs.dir(dir) do
		if ftype == "file" and name:match("%.lua$") then
			files[#files + 1] = name
		end
	end
	table.sort(files)
	for _, name in ipairs(files) do
		local mod = prefix .. "." .. name:gsub("%.lua$", "")
		local ok, err = pcall(require, mod)
		if not ok then
			failed = true
			vim.notify("插件配置加载失败: " .. mod .. "\n" .. tostring(err), vim.log.levels.ERROR)
		end
	end
	return not failed
end
