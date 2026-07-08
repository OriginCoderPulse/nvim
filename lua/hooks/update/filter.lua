local locked = require("hooks.update.locked")

---@param targets? string[]
---@return string[] filtered
---@return string[] skipped
return function(targets)
	local Pack = _G.Pack
	local locked_set = locked.collect_locked()

	if targets then
		local filtered, skipped = {}, {}
		for _, name in ipairs(targets) do
			local parsed = Pack.parse(name)
			if locked_set[parsed] then
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
		if locked_set[name] then
			skipped[#skipped + 1] = name
		else
			filtered[#filtered + 1] = name
		end
	end
	return filtered, skipped
end
