--- LSP 模块共享状态
local M = {
	enabled = {},
	disabled = {},
	filetypes = {},
	listened = false,
	last_buf = -1,
	last_ft = "",
}

---@param name string
---@return string
function M.norm(name)
	return name:gsub("%.lua$", "")
end

return M
