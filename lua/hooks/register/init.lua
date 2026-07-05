--- 递归登记依赖树中的 spec 与引用关系
local function register_dep_tree(dep, consumer_name, disabled, ensure_spec)
	local Pack = _G.Pack
	Pack.track(dep, consumer_name)
	if disabled then
		return
	end
	local item = Pack.norm(dep)
	if item.spec then
		ensure_spec(Pack.active, item.spec)
	end
	if item.deps then
		for _, nested in ipairs(item.deps) do
			register_dep_tree(nested, consumer_name, disabled, ensure_spec)
		end
	end
end

--- 登记 config 中的插件声明（spec / name / module / disabled / deps）
local function register(P)
	local Pack = _G.Pack
	if not P or not P.spec then
		return
	end

	Pack.identity(P)
	P.disabled = P.disabled == true

	--- 按 pack 目录名去重，只查目标列表本身（主插件与依赖不共用 seen）
	local function ensure_spec(spec_list, spec)
		local name = Pack.parse(spec)
		for _, existing in ipairs(spec_list) do
			if Pack.parse(existing) == name then
				return false
			end
		end
		spec_list[#spec_list + 1] = spec
		return true
	end

	if P.deps then
		for _, dep in ipairs(P.deps) do
			register_dep_tree(dep, P.name, P.disabled, ensure_spec)
		end
	end

	if P.disabled then
		ensure_spec(Pack.idle, P.spec)
		Pack.disabled[P.name] = true
	else
		ensure_spec(Pack.active, P.spec)
	end

	Pack.registry[P.name] = P
	P._registered = true
end

return register
