--- 递归登记依赖树中的 spec 与引用关系
local function register_dep_tree(dep, consumer_name, disabled, ensure_spec)
	local PackUtils = _G.PackUtils
	PackUtils.track_dependency(dep, consumer_name)
	if disabled then
		return
	end
	local norm = PackUtils.normalize_dep(dep)
	if norm.spec then
		ensure_spec(PackUtils.active_specs, norm.spec)
	end
	if norm.deps then
		for _, nested in ipairs(norm.deps) do
			register_dep_tree(nested, consumer_name, disabled, ensure_spec)
		end
	end
end

--- 登记 config 中的插件声明（spec / name / module / disabled / deps）
local function register_plugin(P)
	local PackUtils = _G.PackUtils
	if not P or not P.spec then
		return
	end

	PackUtils.resolve_plugin_identity(P)
	P.disabled = P.disabled == true

	--- 按 pack 目录名去重，只查目标列表本身（主插件与依赖不共用 seen）
	local function ensure_spec(spec_list, spec)
		local name = PackUtils.parse_spec_name(spec)
		for _, existing in ipairs(spec_list) do
			if PackUtils.parse_spec_name(existing) == name then
				return false
			end
		end
		spec_list[#spec_list + 1] = spec
		return true
	end

	-- 依赖先入 active_specs，保证 vim.pack.add 按依赖顺序 packadd
	if P.deps then
		for _, dep in ipairs(P.deps) do
			register_dep_tree(dep, P.name, P.disabled, ensure_spec)
		end
	end

	-- 主插件必须登记，不能因为同名依赖已被其他插件登记就跳过
	if P.disabled then
		ensure_spec(PackUtils.disabled_specs, P.spec)
		PackUtils.disabled_plugins[P.name] = true
	else
		ensure_spec(PackUtils.active_specs, P.spec)
	end

	PackUtils.registry[P.name] = P
	P._registered = true
end

return register_plugin
