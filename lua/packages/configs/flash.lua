local P = {
	spec = "https://github.com/folke/flash.nvim",
	module = "flash",
}

Pack.register(P)

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		vim.schedule(function()
			Pack.load(P, function(plugin)
				plugin.setup({})
			end)
		end)
	end,
})
