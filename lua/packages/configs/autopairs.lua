local P = {
	spec = "https://github.com/windwp/nvim-autopairs",
	module = "nvim-autopairs",
}

Pack.register(P)

vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({})
		end)
	end,
})
