if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/windwp/nvim-autopairs",
	module = "nvim-autopairs",
}

PackUtils.register_plugin(P)

vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		PackUtils.load_plugin(P, function(plugin)
			plugin.setup({})
		end)
	end,
})

