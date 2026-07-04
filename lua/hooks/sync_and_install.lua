--- 按依赖拓扑排序 spec，确保 vim.pack.add 先处理依赖再处理主插件
local function sort_specs_by_deps(specs)
	local PackUtils = _G.PackUtils
	local name_to_spec = {}
	for _, spec in ipairs(specs) do
		name_to_spec[PackUtils.parse_spec_name(spec)] = spec
	end

	local sorted_names = {}
	local visited = {}

	local function visit(name)
		if not name_to_spec[name] or visited[name] then
			return
		end

		local P = PackUtils.registry[name]
		if P and P.deps then
			for _, dep in ipairs(P.deps) do
				PackUtils.walk_dep_tree(dep, visit)
			end
		end

		visited[name] = true
		sorted_names[#sorted_names + 1] = name
	end

	for _, spec in ipairs(specs) do
		visit(PackUtils.parse_spec_name(spec))
	end

	local sorted = {}
	for _, name in ipairs(sorted_names) do
		sorted[#sorted + 1] = name_to_spec[name]
	end
	return sorted
end

--- 同步注册表、安装插件、必要时自动重启
local function sync_and_install(active_specs, disabled_specs)
	local PackUtils = _G.PackUtils
	active_specs = active_specs or PackUtils.active_specs
	disabled_specs = disabled_specs or PackUtils.disabled_specs

	PackUtils.synchronize_registry(active_specs, disabled_specs)
	PackUtils.repair_incomplete_plugins()
	vim.pack.add(sort_specs_by_deps(active_specs))
	PackUtils.maybe_restart_after_install()
end

return sync_and_install
