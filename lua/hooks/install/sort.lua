local cycle = require("hooks.deps.cycle")

--- 按依赖拓扑排序 spec，确保 vim.pack.add 先处理依赖再处理主插件
--- Topo-sort specs so vim.pack.add installs deps before consumers
---@param active_specs table
---@return table? sorted nil 表示检测到循环依赖或校验失败
--- nil if cycle detected or validation failed
return function(active_specs)
	local Pack = _G.Pack
	local name_to_spec = {}
	for _, spec in ipairs(active_specs) do
		name_to_spec[Pack.parse(spec)] = spec
	end

	for _, spec in ipairs(active_specs) do
		local name = Pack.parse(spec)
		local P = Pack.registry[name]
		if P and P.deps then
			local ok, err = cycle.check_tree(name, P.deps)
			if not ok then
				vim.notify("install 排序: " .. tostring(err), vim.log.levels.ERROR)
				return nil
			end
		end
	end

	local sorted_names = {}
	local visited = {}
	local visiting = {}

	local function visit(name)
		if visited[name] then
			return true
		end
		if visiting[name] then
			vim.notify("install 排序检测到循环依赖: " .. name, vim.log.levels.ERROR)
			return false
		end
		if not name_to_spec[name] then
			return true
		end

		visiting[name] = true

		local P = Pack.registry[name]
		if P and P.deps then
			for _, dep in ipairs(P.deps) do
				if Pack.walk(dep, visit) == false then
					visiting[name] = nil
					vim.notify("install 排序: 依赖遍历失败 (" .. name .. ")", vim.log.levels.ERROR)
					return false
				end
			end
		end

		visiting[name] = nil
		visited[name] = true
		sorted_names[#sorted_names + 1] = name
		return true
	end

	for _, spec in ipairs(active_specs) do
		if visit(Pack.parse(spec)) == false then
			return nil
		end
	end

	local sorted = {}
	for _, name in ipairs(sorted_names) do
		sorted[#sorted + 1] = name_to_spec[name]
	end
	return sorted
end
