--- 按依赖拓扑排序 spec，确保 vim.pack.add 先处理依赖再处理主插件
local function sort(active_specs)
	local Pack = _G.Pack
	local name_to_spec = {}
	for _, spec in ipairs(active_specs) do
		name_to_spec[Pack.parse(spec)] = spec
	end

	local sorted_names = {}
	local visited = {}

	local function visit(name)
		if not name_to_spec[name] or visited[name] then
			return
		end

		local P = Pack.registry[name]
		if P and P.deps then
			for _, dep in ipairs(P.deps) do
				Pack.walk(dep, visit)
			end
		end

		visited[name] = true
		sorted_names[#sorted_names + 1] = name
	end

	for _, spec in ipairs(active_specs) do
		visit(Pack.parse(spec))
	end

	local sorted = {}
	for _, name in ipairs(sorted_names) do
		sorted[#sorted + 1] = name_to_spec[name]
	end
	return sorted
end

--- 同步注册表、安装插件、必要时自动重启
local function install(active_specs, disabled_specs)
	local Pack = _G.Pack
	active_specs = active_specs or Pack.active
	disabled_specs = disabled_specs or Pack.idle

	Pack.sync(active_specs, disabled_specs)
	Pack.repair()
	vim.pack.add(sort(active_specs), { confirm = false, load = false })
	Pack.relaunch()
end

return install
