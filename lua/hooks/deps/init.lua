--- 解析 deps 条目为 pack 目录名
local function norm(dep)
	local Pack = _G.Pack
	if type(dep) == "table" then
		local spec = dep.src or dep.spec
		if not spec then
			error("dep table must have src or spec")
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

local function depname(dep)
	return norm(dep).name
end

local function shield(dep, protected)
	local item = norm(dep)
	protected[item.name] = true
	if item.deps then
		for _, nested in ipairs(item.deps) do
			shield(nested, protected)
		end
	end
end

local function walk(dep, fn)
	fn(depname(dep))
	local item = norm(dep)
	if item.deps then
		for _, nested in ipairs(item.deps) do
			walk(nested, fn)
		end
	end
end

--- 登记 consumer 对 dep 的引用（允许多个插件共享同一依赖）
local function track(dep, consumer_name)
	local Pack = _G.Pack
	local name = depname(dep)
	local refs = Pack.refs[name]
	if not refs then
		refs = {}
		Pack.refs[name] = refs
	end
	for _, ref in ipairs(refs) do
		if ref == consumer_name then
			return name
		end
	end
	refs[#refs + 1] = consumer_name
	return name
end

--- 依赖是否仍被未禁用的插件使用
local function needed(name)
	local Pack = _G.Pack
	local refs = Pack.refs[name]
	if not refs then
		return false
	end
	for _, consumer in ipairs(refs) do
		local P = Pack.registry[consumer]
		if P and not P.disabled then
			return true
		end
	end
	return false
end

--- 收集应保留的 pack 目录名（主插件 + 仍被引用的依赖）
local function protect()
	local Pack = _G.Pack
	local protected = {}

	for name, P in pairs(Pack.registry) do
		if P.disabled then
			protected[name] = true
		else
			protected[name] = true
			if P.deps then
				for _, dep in ipairs(P.deps) do
					shield(dep, protected)
				end
			end
		end
	end

	return protected
end

--- 列出仍依赖 name 的插件名
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
	norm = norm,
	depname = depname,
	walk = walk,
	track = track,
	needed = needed,
	protect = protect,
	users = users,
}
