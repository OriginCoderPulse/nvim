--- 同步插件注册表：清理孤儿包并登记禁用列表
---@param active_specs? table
---@param disabled_specs? table
return function(active_specs, disabled_specs)
	local Pack = _G.Pack
	active_specs = active_specs or Pack.active
	disabled_specs = disabled_specs or {}

	for _, spec in ipairs(active_specs) do
		local name = Pack.parse(spec)
		Pack.disabled[name] = nil
	end

	for _, spec in ipairs(disabled_specs) do
		local name = Pack.parse(spec)
		Pack.disabled[name] = true
	end

	local protected = Pack.protect()
	local pack_dir = vim.fn.stdpath("data") .. "/site/pack"
	local installed_plugins = {}
	local seen = {}

	if vim.fn.isdirectory(pack_dir) ~= 1 then
		return
	end

	for pkg_name, pkg_type in vim.fs.dir(pack_dir) do
		if pkg_type == "directory" and pkg_name:sub(1, 1) ~= "." then
			for _, type_dir in ipairs({ "start", "opt" }) do
				local dir = pack_dir .. "/" .. pkg_name .. "/" .. type_dir
				if vim.fn.isdirectory(dir) == 1 then
					for name, ftype in vim.fs.dir(dir) do
						if ftype == "directory" and name ~= "doc" and not seen[name] then
							seen[name] = true
							installed_plugins[#installed_plugins + 1] = name
						end
					end
				end
			end
		end
	end

	local to_delete = {}
	local kept_shared = {}

	for _, installed in ipairs(installed_plugins) do
		if protected[installed] then
			goto continue
		end

		if Pack.needed(installed) then
			local dependents = Pack.users(installed)
			kept_shared[#kept_shared + 1] = installed
				.. " (仍被 "
				.. table.concat(dependents, ", ")
				.. " 使用)"
			goto continue
		end

		to_delete[#to_delete + 1] = installed
		::continue::
	end

	if #kept_shared > 0 then
		vim.schedule(function()
			vim.notify(
				"保留共享依赖: " .. table.concat(kept_shared, "; "),
				vim.log.levels.INFO
			)
		end)
	end

	if #to_delete > 0 then
		vim.notify("🧹 Clean Up Orphaned Plugins: " .. table.concat(to_delete, ", "), vim.log.levels.INFO)
		vim.pack.del(to_delete)
		local healthy = require("hooks.deps.healthy")
		for _, name in ipairs(to_delete) do
			local dir = Pack.path(name)
			if dir then
				healthy.invalidate(dir)
			end
		end
	end
end
