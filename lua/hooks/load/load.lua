--- 装载插件：依赖 → packadd（config 由 :load 句柄在 utils/var 就绪后执行）
--- Load plugin: dependencies → packadd (config runs from :load after utils/var are ready)
local notify_once = require("hooks.util.notify_once")
local cycle = require("hooks.deps.cycle")
local prepare = require("hooks.load.prepare")
local load_dep = require("hooks.load.load_dep")
local ensure = require("hooks.build.ensure")

---@param P table
---@return boolean ok
return function(P)
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
			"load(" .. P.name .. "): plugin disabled, skipped",
			vim.log.levels.INFO
		)
		return false
	end

	if not Pack.available(P.name) then
		notify_once(
			"load:missing:" .. P.name,
			"load(" .. P.name .. "): not installed yet, skipped",
			vim.log.levels.WARN
		)
		return false
	end

	if P.dependencies then
		local dep_ok, dep_err = cycle.check_tree(P.name, P.dependencies)
		if not dep_ok then
			notify_once("load:cycle:" .. P.name, dep_err, vim.log.levels.ERROR)
			return false
		end
	end

	if Pack.loaded[P.name] then
		return true
	end

	ensure(P.name, P.build)
	if P.dependencies then
		for _, dep in ipairs(P.dependencies) do
			if not load_dep(dep, P.name, { [P.name] = true }) then
				return false
			end
		end
	end
	local packadd_ok = pcall(vim.cmd.packadd, P.name)
	if not packadd_ok then
		notify_once("load:packadd:" .. P.name, "load(" .. P.name .. "): packadd failed", vim.log.levels.WARN)
		return false
	end
	Pack.loaded[P.name] = true
	notify_once.clear("load:missing:" .. P.name)
	notify_once.clear("load:packadd:" .. P.name)
	return true
end
