--- 停止指定 name 的全部 LSP client
---@param name string
return function(name)
	for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
		client:stop(true)
	end
end
