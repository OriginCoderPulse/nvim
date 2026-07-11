local notify_once = require("hooks.util.notify_once")
local norm = require("hooks.deps.norm")
local ensure = require("hooks.build.ensure")

local load_dep

---@param dep any
---@param consumer_name string
---@param stack? table<string, boolean>
---@param opts? { skip_config?: boolean }
load_dep = function(dep, consumer_name, stack, opts)
	opts = opts or {}
	stack = stack or {}
	local Pack = _G.Pack

	local ok_norm, item = pcall(norm, dep)
	if not ok_norm then
		notify_once(
			"dep:norm:" .. tostring(dep),
			"dependency resolve failed (" .. (consumer_name or "?") .. "): " .. tostring(item),
			vim.log.levels.ERROR
		)
		return false
	end

	if stack[item.name] then
		notify_once(
			"dep:cycle:" .. item.name,
			"dependency cycle: " .. (consumer_name or "?") .. " -> " .. item.name,
			vim.log.levels.ERROR
		)
		return false
	end
	stack[item.name] = true

	if item.dependencies then
		for _, nested in ipairs(item.dependencies) do
			if not load_dep(nested, item.name, stack, opts) then
				stack[item.name] = nil
				return false
			end
		end
	end

	stack[item.name] = nil

	if Pack.disabled[item.name] then
		notify_once(
			"dep:disabled:" .. item.name,
			"dependency " .. item.name .. " disabled (from " .. (consumer_name or "?") .. "), load rejected",
			vim.log.levels.WARN
		)
		return false
	end
	if not Pack.available(item.name) then
		notify_once(
			"dep:missing:" .. item.name,
			"dependency " .. item.name .. " not installed (from " .. (consumer_name or "?") .. "), skipped",
			vim.log.levels.WARN
		)
		return false
	end

	if Pack.loaded[item.name] then
		return true
	end

	ensure(item.name, item.build)
	local dep_ok = pcall(vim.cmd.packadd, item.name)
	if not dep_ok then
		notify_once(
			"dep:packadd:" .. item.name,
			"dependency packadd failed: " .. item.name .. " (from " .. (consumer_name or "?") .. ")",
			vim.log.levels.WARN
		)
		return false
	end

	Pack.loaded[item.name] = true
	notify_once.clear("dep:missing:" .. item.name)
	notify_once.clear("dep:packadd:" .. item.name)
	return true
end

return load_dep
