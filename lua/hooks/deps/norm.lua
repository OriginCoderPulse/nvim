--- 解析 deps 条目为 pack 目录名
---@param dep any
---@return table
return function(dep)
	local Pack = _G.Pack
	if type(dep) == "table" then
		local spec = dep.src or dep.spec
		if not spec then
			error("dep table must have src or spec: " .. vim.inspect(dep))
		end
		local name = dep.name and Pack.parse(dep.name) or Pack.parse(spec)
		return {
			spec = spec,
			name = name,
			module = dep.module or name,
			setup = dep.setup,
			build_cmd = dep.build_cmd,
			deps = dep.deps,
			immediately = dep.immediately == true,
		}
	end
	local name = Pack.parse(dep)
	return {
		spec = dep,
		name = name,
		module = name,
	}
end
