Pack.register({
	spec = "https://github.com/mason-org/mason.nvim",
	module = "mason",
	deps = {
		"https://github.com/mason-org/mason-registry",
	},
}):load({
	event = "BufReadPost",
	once = true,
	config = function(plugin)
		plugin.setup({
			PATH = "prepend",
			ui = {
				width = 0.65,
				height = 0.75,
			},
		})
	end,
})
