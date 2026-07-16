Pack.register({
	spec = {
		src = "https://github.com/kylechui/nvim-surround",
		version = vim.version.range("4.x"),
	},
	module = "nvim-surround",
}):load({
	keys = {
		"ys",
		"ds",
		"cs",
		{ "x", "S" },
	},
	config = function(plugin)
		plugin.setup({})
	end,
})
