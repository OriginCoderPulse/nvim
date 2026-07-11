--- 按依赖树顺序执行 config（packadd 已完成；不再注入主插件 utils/var）
--- Run configs in dependency-tree order (after packadd; no main utils/var injection)
local notify_once = require("hooks.util.notify_once")
local require_utils = require("hooks.load.require_utils")
local call_config = require("hooks.load.call_config")
local norm = require("hooks.deps.norm")
local ensure = require("hooks.build.ensure")

---@param item table
---@return boolean
local function run_config(item)
	if not item.config or _G.Pack.inited[item.name] then
		return true
	end
	if type(item.module) ~= "string" or item.module == "" then
		notify_once(
			"dep:module:" .. item.name,
			"dependency " .. item.name .. " has config but missing module",
			vim.log.levels.ERROR
		)
		return false
	end
	local mod_ok, mod = pcall(require, item.module)
	if not mod_ok then
		notify_once(
			"dep:require:" .. item.name,
			"dependency require failed: " .. item.name .. "\n" .. tostring(mod),
			vim.log.levels.ERROR
		)
		return false
	end
	-- 依赖自身 utils 仍仅用于其 config（主插件 utils 不注入）
	-- Dep-local utils still for its own config only (main utils not injected)
	local dep_utils, utils_err = require_utils(item.utils)
	if not dep_utils then
		notify_once(
			"dep:utils:" .. item.name,
			"dependency utils failed: " .. item.name .. "\n" .. tostring(utils_err),
			vim.log.levels.ERROR
		)
		return false
	end
	local ok, err = call_config(item.config, mod, dep_utils)
	if not ok then
		notify_once(
			"dep:config:" .. item.name,
			"dependency config failed: " .. item.name .. "\n" .. tostring(err),
			vim.log.levels.ERROR
		)
		return false
	end
	_G.Pack.inited[item.name] = true
	ensure(item.name, item.build)
	return true
end

---@param deps any[]?
---@return boolean
local function config_tree(deps)
	if not deps then
		return true
	end
	for _, dep in ipairs(deps) do
		local ok_norm, item = pcall(norm, dep)
		if not ok_norm then
			notify_once(
				"dep:norm:" .. tostring(dep),
				"dependency resolve failed: " .. tostring(item),
				vim.log.levels.ERROR
			)
			return false
		end
		if item.dependencies and not config_tree(item.dependencies) then
			return false
		end
		if not run_config(item) then
			return false
		end
	end
	return true
end

return {
	run = run_config,
	tree = config_tree,
}
