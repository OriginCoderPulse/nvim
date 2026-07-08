--- 懒加载插件并安全执行 setup 回调
local notify_once = require("hooks.util.notify_once")
local cycle = require("hooks.deps.cycle")
local prepare = require("hooks.load.prepare")
local load_dep = require("hooks.load.load_dep")

---@param P table
---@param config_fn? function
---@return boolean ok
return function(P, config_fn)
	local Pack = _G.Pack

	if not prepare(P) then
		return false
	end

	local reg = Pack.registry[P.name]
	if reg then
		P = reg
	end

	if Pack.disabled[P.name] then
		notify_once(
			"load:disabled:" .. P.name,
			"Pack.load(" .. P.name .. "): 插件已禁用，已跳过",
			vim.log.levels.INFO
		)
		return false
	end

	if not Pack.available(P.name) then
		notify_once(
			"load:missing:" .. P.name,
			"Pack.load(" .. P.name .. "): 插件尚未安装，已跳过（安装完成后会自动可用）",
			vim.log.levels.WARN
		)
		return false
	end

	if P.deps then
		local dep_ok, dep_err = cycle.check_tree(P.name, P.deps)
		if not dep_ok then
			notify_once("load:cycle:" .. P.name, dep_err, vim.log.levels.ERROR)
			return false
		end
	end

	if not Pack.loaded[P.name] then
		Pack.ensure(P.name, P.build_cmd)
		if P.deps then
			for _, dep in ipairs(P.deps) do
				if not load_dep(dep, P.name, { [P.name] = true }) then
					return false
				end
			end
		end
		local packadd_ok = pcall(vim.cmd.packadd, P.name)
		if not packadd_ok then
			notify_once("load:packadd:" .. P.name, "Pack.load(" .. P.name .. "): packadd 失败", vim.log.levels.WARN)
			return false
		end
		Pack.loaded[P.name] = true
		notify_once.clear("load:missing:" .. P.name)
		notify_once.clear("load:packadd:" .. P.name)
	end

	if config_fn then
		if Pack.inited[P.name] then
			return true
		end
		local mod
		if P.module then
			local mod_ok, loaded = pcall(require, P.module)
			if not mod_ok then
				Pack.loaded[P.name] = nil
				notify_once(
					"load:require:" .. P.name,
					"Pack.load(" .. P.name .. "): require 失败\n" .. tostring(loaded),
					vim.log.levels.ERROR
				)
				return false
			end
			mod = loaded
		end
		local setup_ok, err = pcall(config_fn, mod)
		if not setup_ok then
			Pack.loaded[P.name] = nil
			notify_once(
				"load:setup:" .. P.name,
				"Pack.load(" .. P.name .. "): setup 失败\n" .. tostring(err),
				vim.log.levels.ERROR
			)
			return false
		end
		Pack.inited[P.name] = true
	end

	return true
end
