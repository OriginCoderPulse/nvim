--- 同步插件注册表：清理孤儿包并登记禁用列表
local function synchronize_registry(_active_specs, disabled_specs)
	local PackUtils = _G.PackUtils
	disabled_specs = disabled_specs or {}

	for _, spec in ipairs(disabled_specs) do
		local name = PackUtils.parse_spec_name(spec)
		PackUtils.disabled_plugins[name] = true
	end

	local protected_names = PackUtils.collect_protected_names()

	-- 没有任何 config 登记插件时，跳过清理，避免误删全部已装包
	if vim.tbl_isempty(protected_names) then
		return
	end

	local pack_dir = vim.fn.stdpath("data") .. "/site/pack"
	local installed_plugins = {}

	if vim.fn.isdirectory(pack_dir) ~= 1 then
		return
	end

	for pkg_name, pkg_type in vim.fs.dir(pack_dir) do
		if pkg_type == "directory" and pkg_name:sub(1, 1) ~= "." then
			for _, type_dir in ipairs({ "start", "opt" }) do
				local path = pack_dir .. "/" .. pkg_name .. "/" .. type_dir
				if vim.fn.isdirectory(path) == 1 then
					for name, ftype in vim.fs.dir(path) do
						if ftype == "directory" and name ~= "doc" then
							table.insert(installed_plugins, name)
						end
					end
				end
			end
		end
	end

	local to_delete = {}
	local kept_shared = {}

	for _, installed in ipairs(installed_plugins) do
		if protected_names[installed] then
			goto continue
		end

		-- 依赖仍被其他插件使用时，不删除
		if PackUtils.is_dependency_needed(installed) then
			local dependents = PackUtils.get_dependents(installed)
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
		vim.schedule(function()
			vim.notify("🧹 Clean Up Orphaned Plugins: " .. table.concat(to_delete, ", "), vim.log.levels.INFO)
			vim.pack.del(to_delete)
		end)
	end
end

return synchronize_registry
