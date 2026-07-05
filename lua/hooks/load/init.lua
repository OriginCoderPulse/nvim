--- 懒加载插件并安全执行 setup 回调
local load_dep

local function configured(dep)
	local Pack = _G.Pack
	return Pack.norm(dep).setup ~= nil
end

local function immed(dep)
	if type(dep) ~= "table" then
		return false
	end
	return dep.setup ~= nil and dep.immediately == true
end

load_dep = function(dep, consumer_name, opts)
	opts = opts or {}
	local Pack = _G.Pack
	local item = Pack.norm(dep)

	if item.deps then
		for _, nested in ipairs(item.deps) do
			load_dep(nested, item.name, opts)
		end
	end

	if Pack.disabled[item.name] then
		return
	end
	if not Pack.available(item.name) then
		return
	end

	if Pack.loaded[item.name] then
		return
	end

	Pack.ensure(item.name, item.build_cmd)
	local dep_ok = pcall(vim.cmd.packadd, item.name)
	if not dep_ok then
		vim.notify(
			"Warning: " .. (consumer_name or "?") .. " dependency[" .. item.name .. "] missing",
			vim.log.levels.WARN
		)
		return
	end

	if item.setup then
		local mod_ok, mod = pcall(require, item.module)
		if not mod_ok then
			vim.notify("Error: " .. item.name .. " require failed: \n" .. tostring(mod), vim.log.levels.ERROR)
			return
		end
		local setup_ok, err = pcall(item.setup, mod)
		if not setup_ok then
			vim.notify("Error: " .. item.name .. " setup failed: \n" .. tostring(err), vim.log.levels.ERROR)
			return
		end
	end

	Pack.loaded[item.name] = true
end

local function eager()
	local Pack = _G.Pack
	for _, P in pairs(Pack.registry) do
		if not P.disabled and P.deps then
			for _, dep in ipairs(P.deps) do
				if immed(dep) then
					load_dep(dep, P.name, { eager = true })
				end
			end
		end
	end
end

local function load(P, config_fn)
	local Pack = _G.Pack
	local info = debug.getinfo(2, "Sl")
	local call_id = (info.short_src or "unknown") .. ":" .. (info.currentline or 0)

	if Pack.inited[call_id] then
		return
	end

	Pack.identity(P)
	if not P.name then
		return
	end

	if P.spec and not P._registered and not Pack.registry[P.name] then
		vim.notify(
			"Warning: " .. P.name .. " 未调用 Pack.register(P)，插件不会被自动安装",
			vim.log.levels.WARN
		)
	end

	if Pack.disabled[P.name] then
		return
	end
	if not Pack.available(P.name) then
		return
	end

	if not Pack.loaded[P.name] then
		Pack.ensure(P.name, P.build_cmd)
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
		Pack.loaded[P.name] = true
	end

	if config_fn then
		local mod
		if P.module then
			local mod_ok, loaded = pcall(require, P.module)
			if not mod_ok then
				Pack.loaded[P.name] = nil
				vim.notify("Error: " .. P.name .. " require failed: \n" .. tostring(loaded), vim.log.levels.ERROR)
				return
			end
			mod = loaded
		end
		local setup_ok, err = pcall(config_fn, mod)
		if not setup_ok then
			Pack.loaded[P.name] = nil
			vim.notify("Error: " .. P.name .. " setup failed: \n" .. tostring(err), vim.log.levels.ERROR)
			return
		end
	end

	Pack.inited[call_id] = true
end

return {
	load = load,
	eager = eager,
	configured = configured,
}
