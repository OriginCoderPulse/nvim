-- tint

Pack.register({
	"https://github.com/OriginCoderPulse/Tint.git",
	module = "tint",
}):load({
	config = function(plugin)
		plugin.setup({
			filetypes = {
				json = "json",
				jsonc = "jsonc",
				json5 = "json5",
				jsonnet = "jsonnet",
				rust = "rust",
				python = "python",
				lua = "lua",
				markdown = "markdown",
				bash = "bash",
				sh = "bash",
				java = "java",
				javascript = "javascript",
				javascriptreact = "javascript",
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
