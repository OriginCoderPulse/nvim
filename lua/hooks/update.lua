local deps = require("hooks.deps")

--- 将依赖树中的插件名写入 locked
local function mark_tree(dep, locked)
	local item = deps.norm(dep)
	locked[item.name] = true
	if item.deps then
		for _, nested in ipairs(item.deps) do
			mark_tree(nested, locked)
		end
	end
end

--- 收集 lock = true 的插件及其全部依赖
local function collect_locked()
	local Pack = _G.Pack
	local locked = {}
	for _, P in pairs(Pack.registry) do
		if P.lock == true then
			locked[P.name] = true
			if P.deps then
				for _, dep in ipairs(P.deps) do
					mark_tree(dep, locked)
				end
			end
		end
	end
	return locked
end

---@param targets? string[]
---@return string[] filtered
---@return string[] skipped
local function filter_targets(targets)
	local Pack = _G.Pack
	local locked = collect_locked()

	if targets then
		local filtered, skipped = {}, {}
		for _, name in ipairs(targets) do
			local parsed = Pack.parse(name)
			if locked[parsed] then
				skipped[#skipped + 1] = parsed
			else
				filtered[#filtered + 1] = parsed
			end
		end
		return filtered, skipped
	end

	local filtered, skipped = {}, {}
	for _, p in ipairs(vim.pack.get(nil, { info = false })) do
		local name = p.spec.name
		if locked[name] then
			skipped[#skipped + 1] = name
		else
			filtered[#filtered + 1] = name
		end
	end
	return filtered, skipped
end

--- 过滤 lock = true 的插件及其依赖后调用 vim.pack.update
---@param targets? string[]
---@param opts? table
local function update(targets, opts)
	local filtered, skipped = filter_targets(targets)

	return vim.pack.update(filtered, opts)
end

return {
	update = update,
	collect_locked = collect_locked,
	filter_targets = filter_targets,
}
