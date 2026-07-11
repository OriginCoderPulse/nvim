Pack.register({
	"https://github.com/folke/flash.nvim",
	module = "flash",
}):load({
	event = "BufReadPost",
	once = true,
	defer = true,
	config = function(plugin)
		plugin.setup({})

		vim.keymap.set({ "n", "x", "o" }, "f", function()
			plugin.jump()
		end, { desc = "Flash" })
	end,
})
