--- 锁定 Pack 上不可整体替换的表字段
--- Seal Pack table fields that must not be wholesale replaced
local SEALED = {
	registry = true,
	active = true,
	idle = true,
	refs = true,
}

---@param pack table
---@return table sealed_pack
return function(pack)
	local store = pack
	return setmetatable({}, {
		__index = store,
		__newindex = function(_, key, value)
			if SEALED[key] then
				error(
					("Pack.%s 不能整体替换（防 sync 误删）。请用 Pack.register() 增删，或逐键修改。"):format(
						key
					),
					2
				)
			end
			store[key] = value
		end,
		__pairs = function()
			return pairs(store)
		end,
	})
end
