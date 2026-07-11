local notify_once = require("hooks.util.notify_once")
local norm = require("hooks.deps.norm")

local mark_tree

---@param dep any
---@param locked table<string, boolean>
mark_tree = function(dep, locked)
	local ok, item = pcall(norm, dep)
	if not ok then
		notify_once(
			"update:dep:" .. tostring(dep),
			"update 依赖解析失败: " .. tostring(item),
			vim.log.levels.ERROR
		)
		return
	end
	locked[item.name] = true
	if item.dependencies then
		for _, nested in ipairs(item.dependencies) do
			mark_tree(nested, locked)
		end
	end
end

--- 收集 lock = true 的主插件及其全部 dependencies（定义一次，整棵树锁定）
--- Collect lock=true plugins and their entire dependency trees (one flag locks the tree)
---@return table<string, boolean>
local function collect_locked()
	local Pack = _G.Pack
	local locked = {}
	for _, P in pairs(Pack.registry) do
		if P.lock == true then
			locked[P.name] = true
			if P.dependencies then
				for _, dep in ipairs(P.dependencies) do
					mark_tree(dep, locked)
				end
			end
		end
	end
	return locked
end

return {
	mark_tree = mark_tree,
	collect_locked = collect_locked,
}
