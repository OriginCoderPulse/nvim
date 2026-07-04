--- 懒加载插件并安全执行 setup 回调
local load_dep

local function dep_has_config(dep)
	local PackUtils = _G.PackUtils
	return PackUtils.normalize_dep(dep).setup ~= nil
end

local function dep_should_eager_load(dep)
	if type(dep) ~= "table" then
		return false
	end
	return dep.setup ~= nil and dep.immediately == true
end

load_dep = function(dep, consumer_name, opts)
	opts = opts or {}
	local PackUtils = _G.PackUtils
	local d = PackUtils.normalize_dep(dep)

	if d.deps then
		for _, nested in ipairs(d.deps) do
			load_dep(nested, d.name, opts)
		end
	end

	if PackUtils.disabled_plugins[d.name] then
		return
	end
	if not PackUtils.is_plugin_available(d.name) then
		return
	end

	if PackUtils.plugin_loaded[d.name] then
		return
	end

	PackUtils.ensure_built(d.name, d.build_cmd)
	local dep_ok = pcall(vim.cmd.packadd, d.name)
	if not dep_ok then
		vim.notify(
			"Warning: " .. (consumer_name or "?") .. " dependency[" .. d.name .. "] missing",
			vim.log.levels.WARN
		)
		return
	end

	if d.setup then
		local mod_ok, mod = pcall(require, d.module)
		if not mod_ok then
			vim.notify("Error: " .. d.name .. " require failed: \n" .. tostring(mod), vim.log.levels.ERROR)
			return
		end
		local setup_ok, err = pcall(d.setup, mod)
		if not setup_ok then
			vim.notify("Error: " .. d.name .. " setup failed: \n" .. tostring(err), vim.log.levels.ERROR)
			return
		end
	end

	PackUtils.plugin_loaded[d.name] = true
end

local function load_eager_deps()
	local PackUtils = _G.PackUtils
	for _, P in pairs(PackUtils.registry) do
		if not P.disabled and P.deps then
			for _, dep in ipairs(P.deps) do
				if dep_should_eager_load(dep) then
					load_dep(dep, P.name, { eager = true })
				end
			end
		end
	end
end

local function load_plugin(P, config_fn)
	local PackUtils = _G.PackUtils
	local info = debug.getinfo(2, "Sl")
	local call_id = (info.short_src or "unknown") .. ":" .. (info.currentline or 0)

	if PackUtils.is_initialized[call_id] then
		return
	end

	PackUtils.resolve_plugin_identity(P)
	if not P.name then
		return
	end

	if P.spec and not P._registered and not PackUtils.registry[P.name] then
		vim.notify(
			"Warning: " .. P.name .. " 未调用 PackUtils.register_plugin(P)，插件不会被自动安装",
			vim.log.levels.WARN
		)
	end

	if PackUtils.disabled_plugins[P.name] then
		return
	end
	if not PackUtils.is_plugin_available(P.name) then
		return
	end

	if not PackUtils.plugin_loaded[P.name] then
		PackUtils.ensure_built(P.name, P.build_cmd)
		if P.deps then
			for _, dep in ipairs(P.deps) do
				load_dep(dep, P.name)
			end
		end
		local packadd_ok = pcall(vim.cmd.packadd, P.name)
		if not packadd_ok then
			vim.notify("Warning: packadd failed for " .. P.name, vim.log.levels.WARN)
			return
		end
		PackUtils.plugin_loaded[P.name] = true
	end

	if config_fn then
		local mod
		if P.module then
			local mod_ok, loaded = pcall(require, P.module)
			if not mod_ok then
				PackUtils.plugin_loaded[P.name] = nil
				vim.notify("Error: " .. P.name .. " require failed: \n" .. tostring(loaded), vim.log.levels.ERROR)
				return
			end
			mod = loaded
		end
		local setup_ok, err = pcall(config_fn, mod)
		if not setup_ok then
			PackUtils.plugin_loaded[P.name] = nil
			vim.notify("Error: " .. P.name .. " setup failed: \n" .. tostring(err), vim.log.levels.ERROR)
			return
		end
	end

	PackUtils.is_initialized[call_id] = true
end

return {
	load_plugin = load_plugin,
	load_eager_deps = load_eager_deps,
	dep_has_config = dep_has_config,
}
