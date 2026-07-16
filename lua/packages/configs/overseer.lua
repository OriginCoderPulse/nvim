Pack.register({
	"https://github.com/stevearc/overseer.nvim",
	module = "overseer",
}):load({
	keys = {
		{
			"n",
			"<leader>fr",
			function(plugin)
				plugin.run()
			end,
			{ desc = "Run overseer task" },
		},
		{
			"n",
			"<leader>ft",
			function(plugin)
				plugin.toggle()
			end,
			{ desc = "Toggle overseer task list" },
		},
	},
	config = function(plugin)
		plugin.setup({
			dap = false,
			task_list = {
				direction = "left",
			},
		})
	end,
})
