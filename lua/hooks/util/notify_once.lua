--- 同 key 只通知一次；可 clear 以便错误恢复后再次提示
local seen = {}

local M = {}

---@param key string
---@param msg string
---@param level? integer
---@return boolean notified
function M.notify(key, msg, level)
	if seen[key] then
		return false
	end
	seen[key] = true
	vim.notify(msg, level or vim.log.levels.WARN)
	return true
end

---@param key? string
function M.clear(key)
	if key then
		seen[key] = nil
	else
		seen = {}
	end
end

setmetatable(M, {
	__call = function(_, key, msg, level)
		return M.notify(key, msg, level)
	end,
})

return M
