Pack.register({
	"https://github.com/stevearc/overseer.nvim",
	module = "overseer",
}):load({
	event = "UIEnter",
	once = true,
	defer = true,
	config = function(plugin)
		plugin.setup({
			dap = false,
			task_list = {
				direction = "left",
			},
		})
	end,
})
