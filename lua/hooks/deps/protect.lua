local norm = require("hooks.deps.norm")

local function shield(dep, protected, stack)
	stack = stack or {}
	local ok, item = pcall(norm, dep)
	if not ok then
		return
	end
	if stack[item.name] then
		return
	end
	stack[item.name] = true
	protected[item.name] = true
	if item.dependencies then
		for _, nested in ipairs(item.dependencies) do
			shield(nested, protected, stack)
		end
	end
	stack[item.name] = nil
end

local function idle_names()
	local Pack = _G.Pack
	local names = {}
	for _, spec in ipairs(Pack.idle) do
		names[Pack.parse(spec)] = true
	end
	return names
end

--- 收集应保留的 pack 目录名（活跃插件 + 显式 idle + 其依赖树）
--- Collect pack dirs to keep (active + explicit idle + their dep trees)
---@return table<string, boolean>
local function protect()
	local Pack = _G.Pack
	local protected = {}
	local idle = idle_names()

	for name, P in pairs(Pack.registry) do
		if P.disabled then
			if idle[name] then
				protected[name] = true
			end
			if P.dependencies then
				for _, dep in ipairs(P.dependencies) do
					shield(dep, protected, {})
				end
			end
		else
			protected[name] = true
			if P.dependencies then
				for _, dep in ipairs(P.dependencies) do
					shield(dep, protected, {})
				end
			end
		end
	end

	return protected
end

--- 列出仍依赖 name 的插件名
--- List plugin names that still depend on name
---@param name string
---@return string[]
local function users(name)
	local Pack = _G.Pack
	local refs = Pack.refs[name] or {}
	local active = {}
	for _, consumer in ipairs(refs) do
		local P = Pack.registry[consumer]
		if P and not P.disabled then
			active[#active + 1] = consumer
		end
	end
	return active
end

return {
	protect = protect,
	users = users,
}
