Pack.register({
	"https://github.com/folke/flash.nvim",
	module = "flash",
}):load({
	keys = {
		{
			{ "n", "x", "o" },
			"f",
			function(plugin)
				plugin.jump()
			end,
			{ desc = "Flash" },
		},
	},
	config = function(plugin)
		plugin.setup({})
	end,
})
