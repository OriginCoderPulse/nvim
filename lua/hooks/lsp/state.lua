--- LSP 模块共享状态
local M = {
	enabled = {},
	disabled = {},
	filetypes = {},
	listened = false,
	--- enable() 已登记「首个 FileType 再激活」
	lazy_pending = false,
	--- listen/sync 已真正跑过（vim.lsp 已触达）
	activated = false,
	last_buf = -1,
	last_ft = "",
}

---@param name string
---@return string
function M.norm(name)
	return name:gsub("%.lua$", "")
end

return M
