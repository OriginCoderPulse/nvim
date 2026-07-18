Pack.register({
	"https://github.com/romus204/tree-sitter-manager.nvim",
	module = "tree-sitter-manager",
}):load({
	event = "UIEnter",
	once = true,
	config = function(plugin)
		plugin.setup({
			parser_dir = vim.fn.stdpath("data") .. "/site/parser",
			query_dir = vim.fn.stdpath("data") .. "/site/queries",
			auto_install = true,
			min_width = 0.6,
			min_height = 0.6,
		})
	end,
})
