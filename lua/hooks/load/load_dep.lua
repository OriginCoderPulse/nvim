local notify_once = require("hooks.util.notify_once")

local load_dep

---@param dep any
---@param item table
---@return boolean
local function run_setup(item)
	if not item.setup or _G.Pack.inited[item.name] then
		return true
	end
	local mod_ok, mod = pcall(require, item.module)
	if not mod_ok then
		notify_once(
			"dep:require:" .. item.name,
			"依赖 require 失败: " .. item.name .. "\n" .. tostring(mod),
			vim.log.levels.ERROR
		)
		return false
	end
	local setup_ok, err = pcall(item.setup, mod)
	if not setup_ok then
		notify_once(
			"dep:setup:" .. item.name,
			"依赖 setup 失败: " .. item.name .. "\n" .. tostring(err),
			vim.log.levels.ERROR
		)
		return false
	end
	_G.Pack.inited[item.name] = true
	return true
end

---@param dep any
---@param consumer_name string
---@param stack? table<string, boolean>
load_dep = function(dep, consumer_name, stack)
	stack = stack or {}
	local Pack = _G.Pack

	local ok_norm, item = pcall(Pack.norm, dep)
	if not ok_norm then
		notify_once(
			"dep:norm:" .. tostring(dep),
			"依赖解析失败 (" .. (consumer_name or "?") .. "): " .. tostring(item),
			vim.log.levels.ERROR
		)
		return false
	end

	if stack[item.name] then
		notify_once(
			"dep:cycle:" .. item.name,
			"循环依赖: " .. (consumer_name or "?") .. " -> " .. item.name,
			vim.log.levels.ERROR
		)
		return false
	end
	stack[item.name] = true

	if item.deps then
		for _, nested in ipairs(item.deps) do
			if not load_dep(nested, item.name, stack) then
				stack[item.name] = nil
				return false
			end
		end
	end

	stack[item.name] = nil

	if Pack.disabled[item.name] then
		notify_once(
			"dep:disabled:" .. item.name,
			"依赖 " .. item.name .. " 已禁用（由 " .. (consumer_name or "?") .. " 引用），已拒绝 load",
			vim.log.levels.WARN
		)
		return false
	end
	if not Pack.available(item.name) then
		notify_once(
			"dep:missing:" .. item.name,
			"依赖 " .. item.name .. " 尚未安装（由 " .. (consumer_name or "?") .. " 引用），已跳过",
			vim.log.levels.WARN
		)
		return false
	end

	if Pack.loaded[item.name] then
		return run_setup(item)
	end

	Pack.ensure(item.name, item.build_cmd)
	local dep_ok = pcall(vim.cmd.packadd, item.name)
	if not dep_ok then
		notify_once(
			"dep:packadd:" .. item.name,
			"依赖 packadd 失败: " .. item.name .. "（由 " .. (consumer_name or "?") .. " 引用）",
			vim.log.levels.WARN
		)
		return false
	end

	Pack.loaded[item.name] = true
	notify_once.clear("dep:missing:" .. item.name)
	notify_once.clear("dep:packadd:" .. item.name)

	if not run_setup(item) then
		Pack.loaded[item.name] = nil
		return false
	end

	return true
end

return load_dep
