Pack.register({
	"https://github.com/folke/flash.nvim",
	module = "flash",
}):load({
	event = "BufReadPost",
	once = true,
	var = {
		jump = {
			use = true,
			callback = function(plugin)
				vim.keymap.set({ "n", "x", "o" }, "f", function()
					plugin.jump()
				end, { desc = "Flash" })
			end,
		},
	},
	config = function(plugin)
		plugin.setup({})
	end,
})
