Pack.register({
	"https://github.com/OriginCoderPulse/Tint.git",
	module = "tint",
}):load({
	event = "UIEnter",
	defer = true,
	config = function(plugin)
		plugin.setup({
			filetypes = {
				json = "json",
				jsonc = "json",
				json5 = "json",
				jsonnet = "json",
				rust = "rust",
				python = "python",
				lua = "lua",
				markdown = "markdown",
				bash = "bash",
				sh = "bash",
				java = "java",
				javascript = "javascript",
				javascriptreact = "tsx",
				typescript = "typescript",
				typescriptreact = "tsx",
				html = "html",
				css = "css",
				scss = "scss",
				yaml = "yaml",
				vue = "vue",
				ruby = "ruby",
			},
			auto_install = true,
		})
	end,
})
