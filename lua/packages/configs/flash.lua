local P = {
	spec = "https://github.com/folke/flash.nvim",
	module = "flash",
}

Pack.register(P)

vim.api.nvim_create_autocmd("BufReadPost", {
	once = true,
	callback = function()
		vim.schedule(function()
			Pack.load(P, function(plugin)
				plugin.setup({})

				vim.keymap.set({ "n", "x", "o" }, "f", function()
					plugin.jump()
				end, { desc = "Flash" })
			end)
		end)
	end,
})
