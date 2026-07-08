local P = {
	spec = "https://github.com/stevearc/conform.nvim",
	deps = {
		{
			src = "https://github.com/mason-org/mason.nvim",
			module = "mason",
			immediately = false,
			setup = function(plugin)
				plugin.setup({
					PATH = "prepend",
					ui = {
						width = 0.65,
						height = 0.75,
					},
				})
			end,
			deps = {
				"https://github.com/mason-org/mason-registry",
			},
		},
	},
	module = "conform",
}

Pack.register(P)

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					markdown = { "oxfmt", "cbfmt" },
					javascript = { "oxfmt" },
					typescript = { "oxfmt" },
					json = { "oxfmt" },
					jsonc = { "oxfmt" },
					json5 = { "oxfmt" },
					jsonnet = { "oxfmt" },
					vue = { "oxfmt" },
					css = { "oxfmt" },
					scss = { "oxfmt" },
					less = { "oxfmt" },
					html = { "oxfmt" },
					rust = { "rustfmt" },
				},
				format_on_save = {
					timeout_ms = 3000,
					lsp_format = "fallback",
				},
				formatters = {
					cbfmt = {
						command = "cbfmt",
						args = {
							"--write",
							"--best-effort",
							"--config",
							vim.fn.expand("~/.config/nvim/cbfmt.toml"),
							"$FILENAME",
						},
						stdin = false,
					},
				},
			})
		end)
	end,
})
