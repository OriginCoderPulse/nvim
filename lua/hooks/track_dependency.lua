--- 解析 deps 条目为 pack 目录名
local function normalize_dep(dep)
	local PackUtils = _G.PackUtils
	if type(dep) == "table" then
		local spec = dep.src or dep.spec
		if not spec then
			error("dep table must have src or spec")
		end
		local name = dep.name and PackUtils.parse_spec_name(dep.name) or PackUtils.parse_spec_name(spec)
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
	local name = PackUtils.parse_spec_name(dep)
	return {
		spec = dep,
		name = name,
		module = name,
	}
end

local function resolve_dep_name(dep)
	return normalize_dep(dep).name
end

local function protect_dep_tree(dep, protected)
	local norm = normalize_dep(dep)
	protected[norm.name] = true
	if norm.deps then
		for _, nested in ipairs(norm.deps) do
			protect_dep_tree(nested, protected)
		end
	end
end

local function walk_dep_tree(dep, fn)
	fn(resolve_dep_name(dep))
	local norm = normalize_dep(dep)
	if norm.deps then
		for _, nested in ipairs(norm.deps) do
			walk_dep_tree(nested, fn)
		end
	end
end

--- 登记 consumer 对 dep 的引用（允许多个插件共享同一依赖）
local function track_dependency(dep, consumer_name)
	local PackUtils = _G.PackUtils
	local dep_name = resolve_dep_name(dep)
	local refs = PackUtils.dep_refs[dep_name]
	if not refs then
		refs = {}
		PackUtils.dep_refs[dep_name] = refs
	end
	for _, name in ipairs(refs) do
		if name == consumer_name then
			return dep_name
		end
	end
	refs[#refs + 1] = consumer_name
	return dep_name
end

--- 依赖是否仍被未禁用的插件使用
local function is_dependency_needed(dep_name)
	local PackUtils = _G.PackUtils
	local refs = PackUtils.dep_refs[dep_name]
	if not refs then
		return false
	end
	for _, consumer in ipairs(refs) do
		local P = PackUtils.registry[consumer]
		if P and not P.disabled then
			return true
		end
	end
	return false
end

--- 收集应保留的 pack 目录名（主插件 + 仍被引用的依赖）
local function collect_protected_names()
	local PackUtils = _G.PackUtils
	local protected = {}

	for name, P in pairs(PackUtils.registry) do
		if P.disabled then
			protected[name] = true
		else
			protected[name] = true
			if P.deps then
				for _, dep in ipairs(P.deps) do
					protect_dep_tree(dep, protected)
				end
			end
		end
	end

	return protected
end

--- 列出仍依赖 dep_name 的插件名
local function get_dependents(dep_name)
	local PackUtils = _G.PackUtils
	local refs = PackUtils.dep_refs[dep_name] or {}
	local active = {}
	for _, consumer in ipairs(refs) do
		local P = PackUtils.registry[consumer]
		if P and not P.disabled then
			active[#active + 1] = consumer
		end
	end
	return active
end

return {
	normalize_dep = normalize_dep,
	resolve_dep_name = resolve_dep_name,
	walk_dep_tree = walk_dep_tree,
	track_dependency = track_dependency,
	is_dependency_needed = is_dependency_needed,
	collect_protected_names = collect_protected_names,
	get_dependents = get_dependents,
}
